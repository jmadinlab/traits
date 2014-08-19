class CreateTraitsValues < ActiveRecord::Migration
  def change
    create_table :traitvalues do |t|
    	t.string :value_name
      t.references :trait, index: true
      t.text :value_description
    	t.timestamps
    end
    
  end
end