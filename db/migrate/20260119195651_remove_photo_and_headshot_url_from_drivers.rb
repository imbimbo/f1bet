class RemovePhotoAndHeadshotUrlFromDrivers < ActiveRecord::Migration[7.1]
  def change
    remove_column :drivers, :photo, :string
    remove_column :drivers, :headshot_url, :string
  end
end
