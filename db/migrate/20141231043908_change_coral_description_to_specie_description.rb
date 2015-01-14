class ChangeCoralDescriptionToSpecieDescription < ActiveRecord::Migration
  def change
    rename_column :species, :coral_description, :specie_description
  end
end
