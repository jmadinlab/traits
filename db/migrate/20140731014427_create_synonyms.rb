class CreateSynonyms < ActiveRecord::Migration
  def change
    create_table :synonyms do |t|
      t.references :coral, index: true
      t.string :synonym_name
      t.text :synonym_notes

      t.timestamps
    end
  end
end
