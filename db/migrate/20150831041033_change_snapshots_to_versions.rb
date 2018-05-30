class ChangeSnapshotsToVersions < ActiveRecord::Migration[4.2]
  def change
    rename_table :versions, :changes
    rename_table :snapshots, :versions
  end
end
