class AddApprovalStatusToAllTables < ActiveRecord::Migration[4.2]
  def change
  	add_column :corals, :approval_status, :string
  	add_column :traits, :approval_status, :string
  	add_column :locations, :approval_status, :string
  	add_column :standards, :approval_status, :string
  	add_column :resources, :approval_status, :string
  	add_column :citations, :approval_status, :string
  end
end
