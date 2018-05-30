class CreateCitations < ActiveRecord::Migration[4.2]
  def change
    create_table :citations do |t|
      t.references :trait, index: true
      t.references :resource, index: true

      t.timestamps
    end
  end
end
