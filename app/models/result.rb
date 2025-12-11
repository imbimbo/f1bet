class Result < ApplicationRecord
  belongs_to :race
  belongs_to :driver

  after_save :update_championship_results
  after_save :update_related_bets

  private

  def update_championship_results
    year = race.date.year

    # Sum points per user for all bets in this year
    users_points = User.joins(:bets)
                       .where(bets: { race_id: Race.where("extract(year from date) = ?", year).select(:id) })
                       .select("users.id, SUM(bets.points) AS total_points")
                       .group("users.id")

    users_points.each_with_index do |user_point, index|
      cr = ChampionshipResult.find_or_initialize_by(user_id: user_point.id, year: year)
      cr.points = user_point.total_points
      cr.rank = nil # Optional: calculate after sorting below
      cr.save!
    end

    # Assign ranks
    ChampionshipResult.where(year: year)
                      .order(points: :desc)
                      .each_with_index do |cr, idx|
      cr.update_column(:rank, idx + 1)
    end
  end

  def update_related_bets
    race.bets.includes(:bet_positions).each do |bet|
      bet.calculate_points!
    end
  end
end
