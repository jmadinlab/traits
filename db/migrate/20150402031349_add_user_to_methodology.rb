class AddUserToMethodology < ActiveRecord::Migration[4.2]
  def change
    add_reference :methodologies, :user, index: true, foreign_key: true
  end
end
