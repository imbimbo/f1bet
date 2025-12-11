class CreateChampionshipResults < ActiveRecord::Migration[7.1]
  def change
    create_table :championship_results do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :year
      t.integer :points
      t.integer :rank

      t.timestamps
    end
  end
end
