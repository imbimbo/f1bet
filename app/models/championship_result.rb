class ChampionshipResult < ApplicationRecord
  belongs_to :user

  validates :year, presence: true
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :rank, numericality: { only_integer: true }, allow_nil: true
end
