class CreateIssues < ActiveRecord::Migration[4.2]
  def change
    create_table :issues do |t|
      t.references :user, index: true
      t.references :observation, index: true
      t.text :issue_description

      t.timestamps
    end
  end
end
