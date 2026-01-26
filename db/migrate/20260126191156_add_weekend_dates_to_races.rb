class AddWeekendDatesToRaces < ActiveRecord::Migration[7.1]
  def change
    add_column :races, :date_start, :datetime
    add_column :races, :date_end, :datetime
  end
end
