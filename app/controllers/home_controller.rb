class HomeController < ApplicationController
  # Ensure user can sign in/out
  before_action :authenticate_user!, only: [:index]

  def index
    # Upcoming races - include all future races (including 2026)
    # Get races with start_time in the future, prioritizing by start_time
    @upcoming_races = Race.where(status: "upcoming")
                          .where("start_time > ?", Time.current)
                          .order(:start_time)

    if current_user
      @total_points = current_user.bets.sum(:points) || 0
      @bets_count   = current_user.bets.count
      @position     = ChampionshipResult.where(year: Time.current.year)
                                        .order(points: :desc)
                                        .pluck(:user_id)
                                        .index(current_user.id) || "–"
    else
      @total_points = 0
      @bets_count   = 0
      @position     = "–"
    end
  end
end
