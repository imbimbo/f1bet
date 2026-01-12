class Race < ApplicationRecord
  has_many :bets
  has_many :results

  SESSION_TYPES = %w[qualifying race].freeze
  STATUSES = %w[upcoming open closed finished].freeze

  validates :name, :race_type, :start_time, :year, presence: true
  validates :race_type, inclusion: { in: SESSION_TYPES }
  validates :status, inclusion: { in: STATUSES }
end
