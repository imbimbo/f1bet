class Bet < ApplicationRecord
  belongs_to :user
  belongs_to :race
  has_many :bet_positions, dependent: :destroy
  has_many :drivers, through: :bet_positions
  accepts_nested_attributes_for :bet_positions, allow_destroy: true, reject_if: proc { |attrs| attrs['driver_id'].blank? || attrs['position'].blank? }


  validates :race_id, uniqueness: { scope: :user_id, message: "You have already placed a bet for this race." }
  validate :not_locked
  validate :exactly_ten_positions_when_submitted

  POINTS_TABLE = {
    1 => 25,
    2 => 18,
    3 => 15,
    4 => 12,
    5 => 10,
    6 => 8,
    7 => 6,
    8 => 4,
    9 => 2,
    10 => 1
  }.freeze

  # Calculate and save points for this bet
  def calculate_points!
    return if race.results.empty?

    total = 0

    bet_positions.find_each do |bp|
      result = race.results.find_by(driver_id: bp.driver_id)
      next unless result

      # exact position hit
      if result.position == bp.position
        total += POINTS_TABLE[result.position] || 0
      end
    end

    update_column(:points, total)
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
