class CreateTraitsValues < ActiveRecord::Migration[4.2]
  def change
    create_table :traitvalues do |t|
    	t.string :value_name
      t.references :trait, index: true
      t.text :value_description
    	t.timestamps
    end
    
  end
end