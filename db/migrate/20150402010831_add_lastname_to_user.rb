class AddLastnameToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_name, :string
    add_column :users, :institution, :string
  end
end
