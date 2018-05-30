class ChangeDatatypeOnMeasurementsAllFieldsFromStringToText < ActiveRecord::Migration[4.2]
   def up
    change_column :measurements, :orig_value, :text, :limit => nil
    change_column :measurements, :precision_type, :text, :limit => nil
    change_column :measurements, :precision, :text, :limit => nil
    change_column :measurements, :precision_upper, :text, :limit => nil
    change_column :measurements, :replicates, :text, :limit => nil
    change_column :measurements, :value_type, :text, :limit => nil
    change_column :measurements, :approval_status, :text, :limit => nil
    change_column :measurements, :notes, :text, :limit => nil
    
    
  end

  def down
    change_column :measurements, :orig_value, :string
	change_column :measurements, :precision_type, :string
	change_column :measurements, :precision, :string
	change_column :measurements, :precision_upper, :string
	change_column :measurements, :replicates, :string
	change_column :measurements, :value_type, :string
	change_column :measurements, :approval_status, :string
	change_column :measurements, :notes, :text
  end
end
