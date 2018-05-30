class ChangeReleasesNamesToReleaseName < ActiveRecord::Migration[4.2]
  def change
    rename_column :releases, :releases_code, :release_code
    rename_column :releases, :releases_date, :release_date
    rename_column :releases, :releases_notes, :release_notes
  end
end
