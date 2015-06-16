class CreateSnapshots < ActiveRecord::Migration
  def change
    create_table :snapshots do |t|
      t.references :user, index: true, foreign_key: true
      t.string :snapshot_code
      t.datetime :snapshot_date
      t.text :snapshot_notes

      t.timestamps null: false
    end
  end
end
