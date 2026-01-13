# app/models/result.rb
class Result < ApplicationRecord
  belongs_to :race
  belongs_to :driver

  after_commit :recalculate_bets, on: [:create, :update]

  private

  def recalculate_bets
    return if only_position_changed?

    race.bets.find_each(&:calculate_points!)
    ChampionshipResultService.recalculate!(race.start_time.year)
  end

  def only_position_changed?
    previous_changes.keys == ["position"]
  end
  
end
