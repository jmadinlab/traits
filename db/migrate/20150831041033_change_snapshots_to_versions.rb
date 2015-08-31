class ChangeSnapshotsToVersions < ActiveRecord::Migration
  def change
    rename_table :versions, :changes
    rename_table :snapshots, :versions
  end
end
