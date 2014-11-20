class ChangeDatatypeOnMeasurementsFromStringToText < ActiveRecord::Migration
 def up
    change_column :measurements, :value, :text, :limit => nil
  end

  def down
    change_column :measurements, :value, :string
  end
end
