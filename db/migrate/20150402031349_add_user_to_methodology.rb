class AddUserToMethodology < ActiveRecord::Migration
  def change
    add_reference :methodologies, :user, index: true, foreign_key: true
  end
end
