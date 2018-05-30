class AddValueTypeToMeasurements < ActiveRecord::Migration[4.2]
  def change
  	add_column :measurements, :value_type, :string
  end
end
