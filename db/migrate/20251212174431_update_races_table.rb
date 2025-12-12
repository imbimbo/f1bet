class UpdateRacesTable < ActiveRecord::Migration[7.1]
  def change
    change_table :races do |t|
      t.remove :race_type, :string

      t.integer :session_type, null: false, default: 2
      t.datetime :start_time
      t.integer :round_number
      t.integer :status, default: 0
      t.integer :year
      t.string :location
      t.string :api_session_id
    end
  end
end
