class CreateTraitsValues < ActiveRecord::Migration
  def change
    create_table :traitvalues do |t|
    	t.string :value_name
        t.integer :trait_id
        t.text :value_description
    	t.timestamps
    end
    
  end
end