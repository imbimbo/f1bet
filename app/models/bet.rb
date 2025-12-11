class Bet < ApplicationRecord
  belongs_to :user
  belongs_to :race
  has_many :bet_positions, dependent: :destroy

  accepts_nested_attributes_for :bet_positions

  # Calculate and save points for this bet
  def calculate_points!
    return unless race.result.present? || race.results.any?

    total = 0

    # Loop through each BetPosition
    bet_positions.includes(:driver).each do |bp|
      # Find official result for this driver
      result = race.results.find_by(driver_id: bp.driver_id)
      next unless result

      # Add points if the position matches
      total += result.points if result.position == bp.position
    end

    update!(points: total)
  end
end
