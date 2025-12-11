class User < ApplicationRecord
  has_many :bets, dependent: :destroy
end
