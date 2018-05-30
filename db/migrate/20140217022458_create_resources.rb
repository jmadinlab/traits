class CreateResources < ActiveRecord::Migration[4.2]
  def change
    create_table :resources do |t|
      t.string :author
      t.integer :year
      t.string :title
      t.string :resource_type
      t.string :doi_isbn
      t.string :journal
      t.string :volume_pages
      t.text :resource_notes
      t.references :user, index: true

      t.timestamps
    end
  end
end
