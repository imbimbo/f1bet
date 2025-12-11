class CreateRaces < ActiveRecord::Migration[7.1]
  def change
    create_table :races do |t|
      t.string :name
      t.date :date
      t.string :race_type

      t.timestamps
    end
  end
end
