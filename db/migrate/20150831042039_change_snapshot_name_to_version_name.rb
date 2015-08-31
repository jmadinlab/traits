class ChangeSnapshotNameToVersionName < ActiveRecord::Migration
  def change
    rename_column :versions, :snapshot_code, :version_code
    rename_column :versions, :snapshot_date, :version_date
    rename_column :versions, :snapshot_notes, :version_notes
  end
end
