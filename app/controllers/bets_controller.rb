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
    @bet = current_user.bets.new(race_id: params[:race_id])

    # Build 10 bet_positions if they don't exist
    10.times { @bet.bet_positions.build } if @bet.bet_positions.empty?
  end

  # GET /bets/1/edit
  def edit
  end

  # POST /bets or /bets.json
  def create
    @bet = current_user.bets.new(bet_params)

    respond_to do |format|
      if @bet.save
        format.html { redirect_to @bet, notice: "Bet created!" }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bets/1 or /bets/1.json
  def update
    respond_to do |format|
      if @bet.update(bet_params)
        format.html { redirect_to @bet, notice: "Bet was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @bet }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bets/1 or /bets/1.json
  def destroy
    @bet.destroy!

    respond_to do |format|
      format.html { redirect_to bets_path, notice: "Bet was successfully destroyed.", status: :see_other }
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

    # Only allow a list of trusted parameters through.
    def bet_params
      params.require(:bet).permit(
        :race_id,
        bet_positions_attributes: [:driver_id, :position]
      )
    end
end
