class ChangeCoralsToSpecies < ActiveRecord::Migration
  def change
    rename_table :corals, :species
  end
end
