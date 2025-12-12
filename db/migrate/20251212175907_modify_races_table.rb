class ModifyRacesTable < ActiveRecord::Migration[7.1]
  def change
    change_table :races do |t|
      # add race_type back
      t.string :race_type

      # remove session_type
      t.remove :session_type

      # change status from integer to string
      # first remove the old column and add new one as string
      t.remove :status
      t.string :status, default: "upcoming"
    end
  end
end
