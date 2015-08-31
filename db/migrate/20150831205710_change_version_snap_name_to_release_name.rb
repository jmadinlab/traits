class ChangeVersionSnapNameToReleaseName < ActiveRecord::Migration
  def change
    rename_table :versions, :releases
    rename_table :changes, :versions

    rename_column :releases, :version_code, :releases_code
    rename_column :releases, :version_date, :releases_date
    rename_column :releases, :version_notes, :releases_notes
  end
end
