class CreateBetPositions < ActiveRecord::Migration[7.1]
  def change
    create_table :bet_positions do |t|
      t.references :bet, null: false, foreign_key: true
      t.references :driver, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
