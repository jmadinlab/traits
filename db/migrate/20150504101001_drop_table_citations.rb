class DropTableCitations < ActiveRecord::Migration
  def change
    drop_table :citations
  end
end
