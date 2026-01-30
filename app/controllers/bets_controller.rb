class BetsController < ApplicationController
  before_action :set_bet, only: %i[ show edit update destroy reopen ]
  before_action :authenticate_user!

  # GET /bets or /bets.json
  def index
    @bets = current_user.bets.includes(:race, :bet_positions)
  end

  # GET /bets/1 or /bets/1.json
  def show
  end

  # GET /bets/new
  def new
    @bet = current_user.bets.find_or_initialize_by(race_id: params[:race_id])

    # Build 10 bet_positions if they don't exist
    if @bet.new_record?
      10.times { @bet.bet_positions.build }
    end
  end

  # GET /bets/1/edit
  def edit
    # If bet is submitted and user wants to edit, reopen it
    # Check if reopen parameter is present (from "Atualizar Aposta" button)
    if params[:reopen].present? && @bet.submitted? && !@bet.locked?
      @bet.submitted = false
      @bet.save
    end
    
    @race = @bet.race
    # Reload bet to ensure we have fresh bet_positions and submitted state
    @bet.reload
    
    # Build complete list of all 20 drivers with bet positions in order
    all_drivers = Driver.all.order(:name)
    bet_drivers = @bet.bet_positions.includes(:driver).order(:position).map(&:driver)
    bet_driver_ids = bet_drivers.map(&:id)
    
    # Get drivers not in bet positions
    remaining_drivers = all_drivers.reject { |d| bet_driver_ids.include?(d.id) }
    
    # Combine: bet drivers in position order, then remaining drivers
    @drivers = bet_drivers + remaining_drivers
  end

  # POST /bets or /bets.json
def create
  # Find or initialize bet for this race (handles case where bet already exists)
  @bet = current_user.bets.find_or_initialize_by(race_id: bet_params[:race_id])
  @bet.assign_attributes(bet_params.except(:bet_positions_attributes))

  # Determine if this is a submission or draft
  # Check commit parameter more flexibly to handle encoding/whitespace issues
  commit_value = params[:commit].to_s.strip
  is_submitting = commit_value == "Confirmar Aposta" || commit_value.include?("Confirmar")
  
  # Debug logging
  Rails.logger.info "=== BET CREATE DEBUG ==="
  Rails.logger.info "Commit param: #{params[:commit].inspect}"
  Rails.logger.info "Is submitting: #{is_submitting.inspect}"
  Rails.logger.info "Bet params present: #{bet_params[:bet_positions_attributes].present?}"

  # Use transaction to ensure all operations complete together
  begin
    Bet.transaction do
      # Save bet first (without setting submitted)
      unless @bet.save
        Rails.logger.error "Bet save failed: #{@bet.errors.full_messages.join(', ')}"
        raise ActiveRecord::Rollback
      end

      # Manually create bet_positions from nested attributes
      if bet_params[:bet_positions_attributes].present?
        # Clear existing positions first to avoid duplicates
        @bet.bet_positions.destroy_all if @bet.persisted?
        
        saved_positions = []
        bet_params[:bet_positions_attributes].each do |position_attrs|
          next if position_attrs[:driver_id].blank? || position_attrs[:position].blank?

          position = position_attrs[:position].to_i

          # If submitting (not a draft), only save positions 1-10
          # If saving draft, save all positions so user can continue working
          if is_submitting && position > 10
            next
          end

          # Skip if we already saved this position (avoid duplicates)
          next if saved_positions.include?(position)

          @bet.bet_positions.create!(
            driver_id: position_attrs[:driver_id],
            position: position
          )
          saved_positions << position
        end
        
        Rails.logger.info "Created #{saved_positions.count} bet positions"
      end

      # Reload to get fresh bet_positions from database
      @bet.reload
      
      # Count positions to verify we have exactly 10 when submitting
      position_count = @bet.bet_positions.reload.count
      Rails.logger.info "Position count after creation: #{position_count}"

      # Now set submitted and save again to trigger validation
      # Validation will check that we have exactly 10 positions when submitting
      if is_submitting
        Rails.logger.info "Setting submitted = true"
        # Verify we have exactly 10 positions before setting submitted
        if position_count != 10
          @bet.errors.add(:base, "Must select exactly 10 drivers for positions 1-10. Currently have #{position_count}.")
          Rails.logger.error "Position count mismatch: #{position_count} != 10"
          raise ActiveRecord::Rollback
        end
        
        @bet.submitted = true
        unless @bet.save
          # Validation failed, rollback and render errors
          Rails.logger.error "Bet save failed after setting submitted: #{@bet.errors.full_messages.join(', ')}"
          raise ActiveRecord::Rollback
        end
        Rails.logger.info "Bet submitted successfully"
      else
        Rails.logger.info "Not submitting (draft save)"
      end
    end

    # After transaction, fetch fresh bet from database to ensure all changes are persisted
    if @bet.persisted?
      @bet = current_user.bets.find(@bet.id)
      @bet.reload # Ensure we have the latest submitted state
    end

    # Get ordered drivers directly from the database to ensure correct order
    ordered_drivers = if @bet.bet_positions.any?
                        @bet.bet_positions
                              .includes(:driver)
                              .order(:position)
                              .map(&:driver)
                      else
                        Driver.all.order(:name)
                      end

    # Both draft and submission stay on the same page with updated grid
    render turbo_stream: turbo_stream.replace(
      "drivers-grid",
      partial: "bets/grid",
      locals: { drivers: ordered_drivers, bet: @bet, race: @bet.race, show_success: is_submitting }
    )
  rescue ActiveRecord::RecordInvalid, ActiveRecord::Rollback => e
    # ERROR: se a validação falhar, renderize o formulário novamente com erros
    @bet.reload if @bet.persisted?
    @race = @bet.race || Race.find(bet_params[:race_id]) if bet_params[:race_id].present?
    
    # Log error for debugging
    Rails.logger.error "Bet creation failed: #{@bet.errors.full_messages.join(', ')}"
    Rails.logger.error "Position count: #{@bet.bet_positions.count}" if @bet.persisted?
    Rails.logger.error "Exception: #{e.class} - #{e.message}"
    
    # Get ordered drivers for error display
    ordered_drivers = if @bet.bet_positions.any?
                        @bet.bet_positions
                              .includes(:driver)
                              .order(:position)
                              .map(&:driver)
                      else
                        Driver.all.order(:name)
                      end
    
    # Build error message
    error_message = @bet.errors.full_messages.any? ? @bet.errors.full_messages.join(", ") : "Erro ao salvar aposta. Verifique se você selecionou exatamente 10 pilotos."
    
    # Render grid with error message
    render turbo_stream: turbo_stream.replace(
      "drivers-grid",
      partial: "bets/grid",
      locals: { 
        drivers: ordered_drivers, 
        bet: @bet, 
        race: @race, 
        error: error_message
      }
    ), status: :unprocessable_entity
  end
end


  # PATCH/PUT /bets/1 or /bets/1.json
def update
  @bet = current_user.bets.find(params[:id])
  @race = @bet.race

  # Determine if this is a submission or draft
  # Check commit parameter more flexibly to handle encoding/whitespace issues
  commit_value = params[:commit].to_s.strip
  is_submitting = commit_value == "Confirmar Aposta" || commit_value.include?("Confirmar")
  
  # Debug logging
  Rails.logger.info "=== BET UPDATE DEBUG ==="
  Rails.logger.info "Bet ID: #{@bet.id}"
  Rails.logger.info "Commit param: #{params[:commit].inspect}"
  Rails.logger.info "Is submitting: #{is_submitting.inspect}"
  Rails.logger.info "Bet params present: #{bet_params[:bet_positions_attributes].present?}"

  # Transaction ensures both steps happen or NEITHER happens (safety)
  begin
    Bet.transaction do
      # Step 1: "Clear the board" (Remove old positions)
      @bet.bet_positions.destroy_all

      # Step 2: Manually create bet_positions from nested attributes
      if bet_params[:bet_positions_attributes].present?
        saved_positions = []
        bet_params[:bet_positions_attributes].each do |position_attrs|
          next if position_attrs[:driver_id].blank? || position_attrs[:position].blank?

          position = position_attrs[:position].to_i

          # If submitting (not a draft), only save positions 1-10
          # If saving draft, save all positions so user can continue working
          if is_submitting && position > 10
            next
          end

          # Skip if we already saved this position (avoid duplicates)
          next if saved_positions.include?(position)

          @bet.bet_positions.create!(
            driver_id: position_attrs[:driver_id],
            position: position
          )
          saved_positions << position
        end
        Rails.logger.info "Created #{saved_positions.count} bet positions"
      end

      # Reload to get fresh bet_positions
      @bet.reload
      
      # Count positions to verify we have exactly 10 when submitting
      position_count = @bet.bet_positions.reload.count
      Rails.logger.info "Position count after creation: #{position_count}"

      # Now set submitted and save again to trigger validation
      # Validation will check that we have exactly 10 positions when submitting
      if is_submitting
        Rails.logger.info "Setting submitted = true"
        # Verify we have exactly 10 positions before setting submitted
        if position_count != 10
          @bet.errors.add(:base, "Must select exactly 10 drivers for positions 1-10. Currently have #{position_count}.")
          Rails.logger.error "Position count mismatch: #{position_count} != 10"
          raise ActiveRecord::Rollback
        end
        
        @bet.submitted = true
        unless @bet.save
          # Validation failed, rollback and render errors
          Rails.logger.error "Bet save failed after setting submitted: #{@bet.errors.full_messages.join(', ')}"
          @bet.reload # Reload to get fresh state after failed save
          raise ActiveRecord::Rollback
        end
        Rails.logger.info "Bet submitted successfully"
      else
        Rails.logger.info "Not submitting (draft save)"
      end
    end

  # Reload bet after transaction to ensure we have fresh state (including submitted flag)
  @bet.reload
  @bet.bet_positions.reload # Also reload associations

  # Get ordered drivers directly from the database to ensure correct order
  ordered_drivers = if @bet.bet_positions.any?
                      @bet.bet_positions
                            .includes(:driver)
                            .order(:position)
                            .map(&:driver)
                    else
                      Driver.all.order(:name)
                    end

  # Handle Turbo Stream response (for inline updates) or redirect (for full page)
  respond_to do |format|
    format.turbo_stream do
      render turbo_stream: turbo_stream.replace(
        "drivers-grid",
        partial: "bets/grid",
        locals: { drivers: ordered_drivers, bet: @bet, race: @race, show_success: is_submitting }
      )
    end
    format.html { redirect_to bets_path, notice: "Aposta atualizada com sucesso!" }
  end

  rescue ActiveRecord::RecordInvalid, ActiveRecord::Rollback
    # If something went wrong, reload the page so they can try again
    @bet.reload
    @drivers = @bet.ordered_drivers
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "drivers-grid",
          partial: "bets/grid",
          locals: { drivers: @drivers, bet: @bet, race: @race, error: @bet.errors.full_messages.join(", ") }
        )
      end
      format.html { render :edit, status: :unprocessable_entity }
    end
  end
end

  # PATCH /bets/1/reopen
  def reopen
    error_message = nil

    if @bet.locked?
      error_message = "A aposta está bloqueada. Não é possível atualizar menos de 5 minutos antes da corrida."
    else
      @bet.submitted = false
      error_message = @bet.errors.full_messages.join(", ") unless @bet.save
    end

    ordered_drivers = @bet.ordered_drivers

    # When called from a Turbo Frame, this HTML response (containing the
    # drivers-grid frame) will replace only that frame in the page.
    render partial: "bets/grid",
           locals: { drivers: ordered_drivers, bet: @bet, race: @bet.race, error: error_message }
  end

  # DELETE /bets/1 or /bets/1.json
  def destroy
    @bet.destroy!

    respond_to do |format|
      format.html { redirect_to bets_path, notice: "Aposta apagada com sucesso.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def my_bets
    @bets = current_user.bets.includes(:race, :bet_positions)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bet
      @bet = current_user.bets.find(params[:id])
    end

def handle_save
  is_submitting = params[:commit] == "Confirmar Aposta"

  # Delete existing positions first
  if @bet.persisted?
    @bet.bet_positions.delete_all
  end

  # Save the bet first (without nested attributes and without setting submitted)
  if @bet.save
    # Now manually create bet_positions from nested attributes
    # Only save the first 10 positions (positions 1-10) when submitting
    # For drafts, save all positions to allow user to work on their prediction
    if bet_params[:bet_positions_attributes].present?
      bet_params[:bet_positions_attributes].each do |position_attrs|
        next if position_attrs[:driver_id].blank? || position_attrs[:position].blank?

        position = position_attrs[:position].to_i

        # If submitting (not a draft), only save positions 1-10
        # If saving draft, save all positions so user can continue working
        if is_submitting && position > 10
          next
        end

        @bet.bet_positions.create!(
          driver_id: position_attrs[:driver_id],
          position: position
        )
      end
    end

    # Reload to get fresh bet_positions from database
    @bet.reload

    # Now set submitted and save again to trigger validation
    # Validation will check that we have exactly 10 positions when submitting
    if is_submitting
      @bet.submitted = true
      if @bet.save
        # Validation passed, continue
      else
        # Validation failed, render errors
        render :new, status: :unprocessable_entity
        return
      end
    end

    # Get ordered drivers directly from the database to ensure correct order
    ordered_drivers = if @bet.bet_positions.any?
                          @bet.bet_positions
                                .includes(:driver)
                                .order(:position)
                                .map(&:driver)
                        else
                          # Fallback if no positions were saved
                          Driver.all.order(:name)
                        end

    # Both draft and submission stay on the same page with updated grid
    render turbo_stream: turbo_stream.replace(
      "drivers-grid",
      partial: "bets/grid",
      locals: { drivers: ordered_drivers, bet: @bet, race: @bet.race, show_success: is_submitting }
    )
  else
    # If save failed, log errors for debugging
    Rails.logger.error "Bet save failed: #{@bet.errors.full_messages.join(', ')}"
    render :new, status: :unprocessable_entity
  end
end

    # Only allow a list of trusted parameters through.
    def bet_params
      params.require(:bet).permit(
        :race_id,
        bet_positions_attributes: [:id, :driver_id, :position, :_destroy]
      )
    end
end

