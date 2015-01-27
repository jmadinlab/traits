class ChangeSecondaryIdToResourceSecondaryId < ActiveRecord::Migration
  def change
    rename_column :observations, :secondary_id, :resource_secondary_id
  end
end
