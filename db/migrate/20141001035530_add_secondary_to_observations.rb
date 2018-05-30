class AddSecondaryToObservations < ActiveRecord::Migration[4.2]
  def change
    add_column :observations, :secondary_id, :integer
  end
end
