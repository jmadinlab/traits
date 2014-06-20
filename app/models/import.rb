class Import
  # switch to ActiveModel::Model in Rails 4
  extend ActiveModel::Model
  include ActiveModel::Conversion
  include ActiveModel::Validations
	
	require 'roo'
  
  attr_accessor :file, :model_name

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def set_model_name(model_name)
    self.model_name = model_name
  end

  def save
    puts "controller_name :"
    puts model_name
    
    imported_products.each do |product|
      if product.errors.any?
        imported_products.each_with_index do |product, index|
          product.errors.full_messages.each do |message|
            errors.add :base, "Row #{index+2}: #{message}"
          end
        end
        return false
      end

    end

    
    if imported_products.map(&:valid?).all? 
      imported_products.each(&:save!)
      true
    else
      imported_products.each_with_index do |product, index|
        product.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_products
    @imported_products ||= load_imported_products
  end

  def load_imported_products

    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      product = model_name.find_by_id(row["id"]) || model_name.new
      
      begin
        product.attributes = row.to_hash
      rescue => error
        product.errors[:base] << "The column headers do not match with fields..."
        product.errors[:base] << error.message
        false
      end
      #puts "product attributes"
      #puts product.attributes["user_id"]
      validate_user(product, product.attributes["user_id"])
      
      if product.attributes["latitude"]
        validate_latitude(product, product.attributes["latitude"], "latitude", -90, 90)
      end

      if product.attributes["longitude"]
        validate_latitude(product, product.attributes["longitude"], "longitude",  -180, 180)
      end

      puts "product info: "
      puts product
      product
    end
  end

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".csv" then Roo::CSV.new(file.path)
    when ".xls" then Roo::Excel.new(file.path)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def validate_user(product, user_id)
    if User.where(id: user_id).nil?
      product.errors[:base] << "Invalid user with id: " + user_id.to_s
    end

  end

  def validate_latitude(product, val, item, start, finish)
    puts "validating #{item}"
    val = val.to_i
    if val < start or val > finish
      product.errors[:base] << "Invalid #{item}: "  + val.to_s + " ( has to be between #{start} and #{finish} ) "
      puts "latitude error"
    end
  end


end
