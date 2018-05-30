class CreateObservations < ActiveRecord::Migration[4.2]
  def change
    create_table :observations do |t|
      t.references :user, index: true
      t.references :location, index: true
      t.references :coral, index: true
      t.references :resource, index: true
      t.boolean :private

      t.timestamps
    end
  end
end
