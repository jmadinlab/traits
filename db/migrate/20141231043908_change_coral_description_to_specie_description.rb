class ChangeCoralDescriptionToSpecieDescription < ActiveRecord::Migration[4.2]
  def change
    rename_column :species, :coral_description, :specie_description
  end
end
