class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    @upcoming_races = Race.where(status: "upcoming")
                          .where("start_time > ?", Time.current)
                          .order(:start_time)

    if current_user
      @total_points = current_user.bets.sum(:points) || 0
      @bets_count   = current_user.bets.count

      # Get championship position (1-based)
      championship_results = ChampionshipResult.where(year: Time.current.year)
                                              .order(points: :desc)
      user_result = championship_results.find_by(user_id: current_user.id)

      if user_result
        # Find 1-based position by points ranking
        # Use points and created_at as tiebreaker for consistent ordering
        ranked_users = championship_results
                       .order(points: :desc, created_at: :asc)
                       .pluck(:user_id)
        @position = ranked_users.index(current_user.id) + 1
      else
        @position = "–"  # No championship entry yet
      end
    else
      @total_points = 0
      @bets_count   = 0
      @position     = "–"
    end
  end
end
