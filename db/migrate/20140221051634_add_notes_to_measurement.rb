class AddNotesToMeasurement < ActiveRecord::Migration
  def change
    add_column :measurements, :notes, :text
  end
end
