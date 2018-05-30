class AddLogToTrait < ActiveRecord::Migration[4.2]
  def change
    add_column :traits, :log_data, :boolean
  end
end
