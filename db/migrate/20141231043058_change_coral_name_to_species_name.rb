class ChangeCoralNameToSpeciesName < ActiveRecord::Migration[4.2]
  def change
    rename_column :species, :coral_name, :specie_name
  end
end
