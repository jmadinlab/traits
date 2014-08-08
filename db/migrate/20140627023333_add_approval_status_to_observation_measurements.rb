class AddApprovalStatusToObservationMeasurements < ActiveRecord::Migration
  def change
    add_column :observations, :approval_status, :string
    add_column :measurements, :approval_status, :string
  end
end
