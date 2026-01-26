# app/models/result.rb
class Result < ApplicationRecord
  belongs_to :race
  belongs_to :driver

  after_commit :recalculate_bets, on: [:create, :update]

  private

  def recalculate_bets
    return unless race.results.count >= 10

    race.bets.find_each(&:calculate_points!)
    ChampionshipResultService.recalculate!(race.start_time.year)
  end
end
