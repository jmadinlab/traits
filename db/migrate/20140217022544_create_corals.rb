class CreateCorals < ActiveRecord::Migration
  def change
    create_table :corals do |t|
      t.string :coral_name
      t.text :coral_description
      t.references :user, index: true

      t.timestamps
    end
  end
end
