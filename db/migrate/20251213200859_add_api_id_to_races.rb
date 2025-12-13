class AddApiIdToRaces < ActiveRecord::Migration[7.1]
  def change
    add_column :races, :api_id, :integer
    add_index :races, :api_id
  end
end
