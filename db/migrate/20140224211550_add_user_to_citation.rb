class AddUserToCitation < ActiveRecord::Migration[4.2]
  def change
    add_reference :citations, :user, index: true
  end
end
