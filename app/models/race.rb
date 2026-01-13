class Race < ApplicationRecord
  has_many :bets
  has_many :results, -> { order(:position) }, dependent: :destroy
  has_many :drivers, through: :results
  belongs_to :drivers

  SESSION_TYPES = %w[qualifying race].freeze
  STATUSES = %w[upcoming open closed finished].freeze

  validates :name, :race_type, :start_time, :year, presence: true
  validates :race_type, inclusion: { in: SESSION_TYPES }
  validates :status, inclusion: { in: STATUSES }
  def race_type_label
    I18n.t("races.types.#{race_type}")
  end
end
