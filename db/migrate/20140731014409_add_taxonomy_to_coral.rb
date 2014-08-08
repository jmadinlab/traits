class AddTaxonomyToCoral < ActiveRecord::Migration
  def change
    add_column :corals, :major_clade, :string
    add_column :corals, :family_molecules, :string
    add_column :corals, :family_morphology, :string
  end
end
