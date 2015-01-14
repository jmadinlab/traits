class ChangeCoralNameToSpeciesName < ActiveRecord::Migration
  def change
    rename_column :species, :coral_name, :specie_name
  end
end
