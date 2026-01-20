class Driver < ApplicationRecord
  has_many :race_drivers, dependent: :destroy
  has_many :races, through: :race_drivers

  has_many :results
  has_many :bet_positions
end
