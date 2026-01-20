class CreateRaceDrivers < ActiveRecord::Migration[7.1]
  def change
    create_table :race_drivers do |t|
      t.references :race, null: false, foreign_key: true
      t.references :driver, null: false, foreign_key: true

      t.timestamps
    end

      add_index :race_drivers, [:race_id, :driver_id], unique: true

  end
end
