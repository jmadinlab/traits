class AddReleaseToTrait < ActiveRecord::Migration[4.2]
  def change
    add_column :traits, :release_status, :string
  end
end
