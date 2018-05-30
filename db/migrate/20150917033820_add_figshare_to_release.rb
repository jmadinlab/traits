class AddFigshareToRelease < ActiveRecord::Migration[4.2]
  def change
    add_column :releases, :release_link, :string
  end
end
