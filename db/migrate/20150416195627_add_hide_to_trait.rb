class AddHideToTrait < ActiveRecord::Migration[4.2]
  def change
    add_column :traits, :hide, :boolean
  end
end
