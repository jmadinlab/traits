class AddApprovalStatusToObservationMeasurements < ActiveRecord::Migration[4.2]
  def change
    add_column :observations, :approval_status, :string
    add_column :measurements, :approval_status, :string
  end
end
