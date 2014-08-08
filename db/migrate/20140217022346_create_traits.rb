class CreateTraits < ActiveRecord::Migration
  def change
    create_table :traits do |t|
      t.string :trait_name
      t.references :standard, index: true
      t.string :value_range
      t.string :trait_class
      t.text :trait_description
      t.references :user, index: true

      t.timestamps
    end
  end
end
