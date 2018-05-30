class ChangeCoralsToSpecies < ActiveRecord::Migration[4.2]
  def change
    rename_table :corals, :species
  end
end
