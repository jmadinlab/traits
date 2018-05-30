class ChangeDatatypeOnResourcesJournalResourceNotesFromStringToText < ActiveRecord::Migration[4.2]
   def up
    change_column :resources, :journal, :text, :limit => nil
    change_column :resources, :resource_notes, :text, :limit => nil
  end

  def down
    change_column :resources, :journal, :string
    change_column :resources, :resource_notes, :string
  end
end
