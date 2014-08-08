class AddUserToCitation < ActiveRecord::Migration
  def change
    add_reference :citations, :user, index: true
  end
end
