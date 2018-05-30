class AddNotesToMeasurement < ActiveRecord::Migration[4.2]
  def change
    add_column :measurements, :notes, :text
  end
end
