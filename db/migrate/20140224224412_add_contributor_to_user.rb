class AddContributorToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :contributor, :boolean
  end
end
