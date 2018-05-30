class AddResolutionToIssues < ActiveRecord::Migration[4.2]
  def change
    add_column :issues, :resolved, :boolean
    add_column :issues, :resolved_description, :text
    add_column :issues, :resolved_user, :integer
  end
end
