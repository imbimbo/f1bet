class AddSubmittedToBets < ActiveRecord::Migration[7.1]
  def change
    add_column :bets, :submitted, :boolean, default: false
  end
end
