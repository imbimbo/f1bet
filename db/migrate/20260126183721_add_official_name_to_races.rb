class AddOfficialNameToRaces < ActiveRecord::Migration[7.1]
  def change
    add_column :races, :official_name, :string
  end
end
