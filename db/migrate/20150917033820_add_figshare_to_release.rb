class AddFigshareToRelease < ActiveRecord::Migration
  def change
    add_column :releases, :release_link, :string
  end
end
