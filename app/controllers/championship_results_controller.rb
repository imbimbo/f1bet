class ChampionshipResultsController < ApplicationController
  before_action :authenticate_user!

  def index
    @year = params[:year] || Time.current.year
    @championship_results = ChampionshipResult.where(year: @year)
                                              .includes(:user)
                                              .order(points: :desc, created_at: :asc)

    # Get top 3 for special display
    @top_three = @championship_results.first(3)
    @rest = @championship_results.offset(3)

    # Find current user's position
    @user_result = @championship_results.find_by(user_id: current_user.id)
    if @user_result
      @user_position = @championship_results.pluck(:user_id).index(current_user.id) + 1
    end
  end
end
