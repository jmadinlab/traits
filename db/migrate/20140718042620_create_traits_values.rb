class CreateTraitsValues < ActiveRecord::Migration
  def change
    create_table :traitvalues do |t|
    	t.string :value_name

    	t.timestamps
    end
    
    create_table :traits_traitvalues, id: false do |t|
			t.belongs_to :trait
			t.belongs_to :traitvalue
    end

    #add_column :measurements, :traitvalue_id, :integer
    #add_index :measurements, :traitvalue_id

  end
end