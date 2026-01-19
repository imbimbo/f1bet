class AddHeadshotUrlToDrivers < ActiveRecord::Migration[7.1]
  def change
    add_column :drivers, :headshot_url, :string
  end
end
