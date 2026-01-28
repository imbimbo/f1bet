class BetPositionsController < ApplicationController
  before_action :set_bet_position, only: %i[ show edit update destroy ]

  # GET /bet_positions or /bet_positions.json
  def index
    # Get all submitted bets for the current user with their positions
    @bets = current_user.bets
                        .where(submitted: true)
                        .includes(:race, bet_positions: :driver)
                        .order(created_at: :desc)
  end

  # GET /bet_positions/1 or /bet_positions/1.json
  def show
  end

  # GET /bet_positions/new
  def new
    @bet_position = BetPosition.new
  end

  # GET /bet_positions/1/edit
  def edit
  end

  # POST /bet_positions or /bet_positions.json
  def create
    @bet_position = BetPosition.new(bet_position_params)

    respond_to do |format|
      if @bet_position.save
        format.html { redirect_to @bet_position, notice: "Bet position was successfully created." }
        format.json { render :show, status: :created, location: @bet_position }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bet_position.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bet_positions/1 or /bet_positions/1.json
  def update
    respond_to do |format|
      if @bet_position.update(bet_position_params)
        format.html { redirect_to @bet_position, notice: "Bet position was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @bet_position }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bet_position.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bet_positions/1 or /bet_positions/1.json
  def destroy
    @bet_position.destroy!

    respond_to do |format|
      format.html { redirect_to bet_positions_path, notice: "Bet position was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bet_position
      @bet_position = BetPosition.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def bet_position_params
      params.require(:bet_position).permit(:bet_id, :driver_id, :position)
    end
end
