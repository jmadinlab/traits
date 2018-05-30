class ChangeDatatypeOnResourcesFromStringToText < ActiveRecord::Migration[4.2]
  def up
    change_column :resources, :author, :text, :limit => nil
  end

  def down
    change_column :resources, :author, :string
  end
end
