class ChangeDatatypeOnResourcesFromStringToText < ActiveRecord::Migration
  def up
    change_column :resources, :author, :text, :limit => nil
  end

  def down
    change_column :resources, :author, :string
  end
end
