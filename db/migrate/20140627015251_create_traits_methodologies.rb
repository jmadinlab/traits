class CreateTraitsMethodologies < ActiveRecord::Migration
  def change
    create_table :methodologies do |t|
    	t.string   :methodology_name
      t.text  :method_description
      #t.belongs_to :measurement

      t.timestamps
    end

    create_table :methodologies_traits, id: false do |t|
			t.belongs_to :trait
			t.belongs_to :methodology
    end

    add_column :measurements, :methodology_id, :integer
    add_index :measurements, :methodology_id
  end
end
