class ChangeDatatypeOnResourcesAllFromStringToText < ActiveRecord::Migration
   def up
    change_column :resources, :title, :text, :limit => nil
    change_column :resources, :resource_type, :text, :limit => nil
    change_column :resources, :doi_isbn, :text, :limit => nil
    change_column :resources, :volume_pages, :text, :limit => nil
    change_column :resources, :approval_status, :text, :limit => nil

  end

  def down
    change_column :resources, :title, :string
    change_column :resources, :resource_type, :string
    change_column :resources, :doi_isbn, :string
    change_column :resources, :volume_pages, :string
    change_column :resources, :approval_status, :string
  end
end
