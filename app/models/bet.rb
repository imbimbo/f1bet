class Bet < ApplicationRecord
  belongs_to :user
  belongs_to :race
  has_many :bet_positions, dependent: :destroy
  has_many :drivers, through: :bet_positions
  accepts_nested_attributes_for :bet_positions, allow_destroy: true, reject_if: proc { |attrs| attrs['driver_id'].blank? || attrs['position'].blank? }


  validates :race_id, uniqueness: { scope: :user_id, message: "You have already placed a bet for this race." }
  validate :not_locked
  validate :exactly_ten_positions_when_submitted

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

  def locked?
    return false unless race

    Time.current >= race.start_time - 5.minutes
  end

  def not_locked
    errors.add(:base, "Bet is locked") if locked?
  end

  # Salva o rascunho na ordem correta dos drivers
  def ordered_drivers
    # Se a aposta já foi salva e tem posições, retorna os drivers na ordem das posições
    # Use reload to ensure we get fresh data from the database
    if persisted?
      positions = bet_positions.reload.order(:position)
      if positions.any?
        positions.includes(:driver).map(&:driver)
      else
        Driver.all.order(:name)
      end
    else
      Driver.all.order(:name)
    end
  end

  def exactly_ten_positions_when_submitted
    if submitted? && bet_positions.count != 10
      errors.add(:base, "Must select exactly 10 drivers for positions 1-10")
    end
  end
end
