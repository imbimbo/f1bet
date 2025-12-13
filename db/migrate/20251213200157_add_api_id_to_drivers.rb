class AddApiIdToDrivers < ActiveRecord::Migration[7.1]
  def change
    add_column :drivers, :api_id, :integer
    add_index :drivers, :api_id
  end
end
