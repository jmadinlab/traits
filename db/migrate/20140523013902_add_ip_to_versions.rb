class AddIpToVersions < ActiveRecord::Migration[4.2]
  def change
    add_column :versions, :ip, :string
  end
end
