class ChangeSynonymCoralIdToSpecieId < ActiveRecord::Migration[4.2]
  def change
    rename_column :synonyms, :coral_id, :specie_id
    rename_column :observations, :coral_id, :specie_id
  end
end
