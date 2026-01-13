class Driver < ApplicationRecord
  has_many :bet_positions
  has_many :results
  has_many :races, through: :results
end
