class AddSecondaryToObservations < ActiveRecord::Migration
  def change
    add_column :observations, :secondary_id, :integer
  end
end
