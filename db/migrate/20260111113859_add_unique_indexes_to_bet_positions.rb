class AddUniqueIndexesToBetPositions < ActiveRecord::Migration[7.1]
  def change
    add_index :bet_positions, [:bet_id, :position], unique: true
    add_index :bet_positions, [:bet_id, :driver_id], unique: true
  end
end
