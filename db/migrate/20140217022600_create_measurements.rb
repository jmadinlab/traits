class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.references :observation, index: true
      t.references :user, index: true
      t.integer :orig_user_id
      t.references :trait, index: true
      t.references :standard, index: true
      t.string :value
      t.string :orig_value
      t.string :precision_type
      t.string :precision
      t.string :precision_upper
      t.string :replicates

      t.timestamps
    end
  end
end
