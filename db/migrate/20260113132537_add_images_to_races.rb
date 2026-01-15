class AddImagesToRaces < ActiveRecord::Migration[7.1]
  def change
    add_column :races, :circuit_image_url, :string
    add_column :races, :country_flag_url, :string
  end
end
