class AddReleaseToTrait < ActiveRecord::Migration
  def change
    add_column :traits, :release_status, :string
  end
end
