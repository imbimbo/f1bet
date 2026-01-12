class AddUniqueIndexToBets < ActiveRecord::Migration[7.1]
  def change
    add_index :bets, [:user_id, :race_id], unique: true
  end
end
