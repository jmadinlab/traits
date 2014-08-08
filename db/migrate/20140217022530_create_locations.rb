class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :location_name
      t.decimal :latitude
      t.decimal :longitude
      t.text :location_description
      t.references :user, index: true

      t.timestamps
    end
  end
end
