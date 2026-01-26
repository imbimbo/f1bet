class Race < ApplicationRecord
  has_many :race_drivers, dependent: :destroy
  has_many :drivers, through: :race_drivers
  has_many :bets
  has_many :results, -> { order(:position) }, dependent: :destroy

  SESSION_TYPES = %w[qualifying race].freeze
  STATUSES = %w[upcoming open closed finished].freeze

  validates :name, :race_type, :start_time, :year, presence: true
  validates :race_type, inclusion: { in: SESSION_TYPES }
  validates :status, inclusion: { in: STATUSES }

  scope :ordered_for_calendar, -> {
    order(
      :start_time,
      Arel.sql(
        "CASE race_type
          WHEN 'qualifying' THEN 1
          WHEN 'race' THEN 2
        END"
      )
    )
  }

  def race_type_label
    I18n.t("races.types.#{race_type}")
  end

  def locked?
    return false if start_time.blank?
    # Lock bets 5 minutes before race start
    Time.current >= (start_time - 5.minutes)
  end

  def lock_time
    return nil if start_time.blank?
    start_time - 5.minutes
  end

  def time_until_lock
    return nil if start_time.blank? || locked?
    distance_of_time_in_words(Time.current, lock_time)
  end

  # Optional: Helper for display
  def betting_status
    if locked?
      "Bloqueado"
    elsif start_time.blank?
      "Horário indefinido"
    else
      "Aberto (fecha em #{time_until_lock})"
    end
  end
end
