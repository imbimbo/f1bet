# app/models/result.rb
class Result < ApplicationRecord
  belongs_to :race
  belongs_to :driver

  after_create :update_championship_results

  private

  def update_championship_results
    # Calculate total points per user for the race year
    year = race.date.year

    # SQLite-compatible: use strftime
    users_with_points = User.joins(:bets)
      .where(bets: { race_id: Race.where("strftime('%Y', date) = ?", year.to_s).select(:id) })
      .group('users.id')
      .sum('bets.points')

    # Update championship results
    users_with_points.each_with_index do |(user_id, points), index|
      champ = ChampionshipResult.find_or_initialize_by(user_id: user_id, year: year)
      champ.points = points
      champ.rank = nil # Optional: calculate ranks later
      champ.save!
    end
  end
end
