class AddLogToTrait < ActiveRecord::Migration
  def change
    add_column :traits, :log_data, :boolean
  end
end
