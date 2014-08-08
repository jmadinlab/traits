class AddValueTypeToMeasurements < ActiveRecord::Migration
  def change
  	add_column :measurements, :value_type, :string
  end
end
