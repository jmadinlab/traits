class Import
  # switch to ActiveModel::Model in Rails 4
  extend ActiveModel::Model
  include ActiveModel::Conversion
  include ActiveModel::Validations
	
	require 'roo'

  # Declare a global variable measurements to store all the measurement objects
  $measurements = []
  
  attr_accessor :file, :model_name

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  # Function to set the model name for further processing
  # Can be called by the controller to pass model name
  # Important to let this same import functionality for all the models
  def set_model_name(model_name)
    self.model_name = model_name
  end

  def check_add_errors(items)
    # First Check if there is any error in the items in the list
    # If any errors are present, don't attempt to save. Just Return False
    flag = false
    items.each_with_index do |item, index|
      if item.errors.any?
        item.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
        flag = true
      end
    end
    return flag
  end

  def save
    puts "controller_name :"
    puts model_name
    
    any_error = check_add_errors(imported_products)
    # If there's any error, dont override its value
    # If there's no any error, check if error is present in measurements
    if not $measurements.empty?
      any_error ? check_add_errors($measurements) : any_error = check_add_errors($measurements)
    end
    
    # If there is any error, dont attempt to save
    if any_error
      return false
    end    

    
    # If no validation errors, see if there is any mapping error
    # If there is a mapping error, display it and then return
    # If there is no any error, then save it
    if imported_products.map(&:valid?).all? 
      imported_products.each(&:save!)
      true
    else
      errors.add :base, "Mapping Error"
      false
    end
  end

  def imported_products
    @imported_products ||= load_imported_products
  end

  def load_imported_products

    spreadsheet = open_spreadsheet
    
    header = spreadsheet.row(1)
    observation_csv_headers = ["observation_id", "access", "enterer", "coral", "location_name", "latitude", "longitude", "resource_id", "measurement_id", "trait_name", "standard_unit", "value", "precision", "precision_type", "precision_upper", "replicates"]

    if header == observation_csv_headers
      # Rename some headers to correspond the database fields
      header[header.index("observation_id")] = "id"
      header[header.index("access")] = "private"
      header[header.index("enterer")] = "user_id"
      

      (2..spreadsheet.last_row).map do |i|

        row = Hash[[header, spreadsheet.row(i)].transpose]
        #puts row
        if row["private"] == "0"
          row["private"] = true
        else
          row["private"] = false
        end

        coral_id = Coral.where(:coral_name => row["coral"]).take!.id
        
        begin
          location_id = Location.where(:location_name => row["location_name"]).take!.id
        rescue
          location_id = nil
        end

        begin
          trait_id = Trait.where(:trait_name => row["trait_name"]).take!.id
        rescue
          trait_id = nil
        end

        begin
          standard_id = Standard.where(:standard_unit => row["standard_unit"]).take!.id
        rescue
          puts "standard error: "
          puts row["standard_unit"]
          puts row["id"]
          standard_id = nil
        end

        observation_row = {"id" => row["id"], "user_id" => row["user_id"], "location_id" => location_id, "coral_id" => coral_id, "resource_id" => row["resource_id"], "private" => row["private"]}

        observation = Observation.find_by_id(row["id"]) || Observation.new

        measurement = Measurement.find_by_id(row["measurement_id"]) || Measurement.new
        
        measurement_row = {"id" => row["measurement_id"], "user_id" => row["user_id"], "observation_id" => row["id"], "trait_id" => trait_id, "standard_id" => standard_id,  "value" => row["value"], "precision" => row["precision"], "precision_type" => row["precision_type"], "precision_upper" => row["precision_upper"], "replicates" => row["replicates"]}
        
        begin
          observation.attributes = observation_row.to_hash
          measurement.attributes = measurement_row.to_hash
        rescue => error
          observation.errors[:base] << "The column headers do not match with fields..."
          observation.errors[:base] << error.message
          false
        end
        
        begin
          measurement.attributes = measurement_row.to_hash
        rescue => error
          measurement.errors[:base] << "The column headers do not match with fields..."
          measurement.errors[:base] << error.message
          false
        end
        measurement.approval_status = "pending"
        $measurements.append(measurement)

        #observation.approval_status = "pending"
        
        puts "====================================="
        #puts observation
        #puts observation.attributes
        observation.approval_status = "pending"
        observation
      end
    else
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
        
        # Validate user_id
        validate_user(product, product.attributes["user_id"])
        
        # Validate latitude
        if product.attributes["latitude"]
          validate_latitude(product, product.attributes["latitude"], "latitude", -90, 90)
        end
        
        # Validate longitude
        if product.attributes["longitude"]
          validate_latitude(product, product.attributes["longitude"], "longitude",  -180, 180)
        end

        # Finally return the product
        product.approval_status = "pending"
        product
      end

    end

  end
    
    
  

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".csv" then Roo::CSV.new(file.path, csv_options: {encoding: Encoding::ISO_8859_1})
    when ".xls" then Roo::Excel.new(file.path)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def validate_user(product, user_id)
    if User.where(id: user_id).empty?
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
