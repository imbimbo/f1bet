class BetsController < ApplicationController
  before_action :set_bet, only: %i[ show edit update destroy ]
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
  end

  # POST /bets or /bets.json
def create
  @bet = Bet.new(bet_params.except(:bet_positions_attributes))
  @bet.user = current_user

  # Determine if this is a submission or draft
  is_submitting = params[:commit] == "Confirmar Aposta"

  # Save bet first (without setting submitted)
  if @bet.save
    # Manually create bet_positions from nested attributes
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
    
    # Reload to get fresh bet_positions
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
                        Driver.all.order(:name)
                      end
    
    # Both draft and submission stay on the same page with updated grid
    render turbo_stream: turbo_stream.replace(
      "drivers-grid",
      partial: "bets/grid",
      locals: { drivers: ordered_drivers, bet: @bet, race: @bet.race, show_success: is_submitting }
    )
  else
    # ERROR: se a validação falhar, renderize o formulário novamente com erros
    render :new
  end
end


  # PATCH/PUT /bets/1 or /bets/1.json
  def update
    # Assign attributes except bet_positions_attributes (we'll handle those manually)
    @bet.assign_attributes(bet_params.except(:bet_positions_attributes))
    handle_save
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
      @bet = Bet.find(params[:id])
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
