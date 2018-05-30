class ChangeSecondaryIdToResourceSecondaryId < ActiveRecord::Migration[4.2]
  def change
    rename_column :observations, :secondary_id, :resource_secondary_id
  end
end
