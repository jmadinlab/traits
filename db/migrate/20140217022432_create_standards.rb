class CreateStandards < ActiveRecord::Migration
  def change
    create_table :standards do |t|
      t.string :standard_name
      t.string :standard_unit
      t.string :standard_class
      t.string :standard_description
      t.references :user, index: true

      t.timestamps
    end
  end
end
