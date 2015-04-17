class AddHideToTrait < ActiveRecord::Migration
  def change
    add_column :traits, :hide, :boolean
  end
end
