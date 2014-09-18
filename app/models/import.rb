class Import
  extend ActiveModel::Model
  include ActiveModel::Conversion
  include ActiveModel::Validations

  require 'roo'

  """
    Upload the csv into the database
    Csv will contain a number of measurements grouped together by observation group number
    Each observation group contains a number of measurements
    For each observation group, only one observation is created
    Each row in csv represents a new measurement
  """

  # Declare a global variable measurements to store all the measurement objects
  $measurements = []
  
  # Map the observation group number in csv spreadsheet to a newly created observation id
  # Format : { '1' => 90613, '2' => 90614 }
  $observation_id_map = {}
  
  $email_list = []
  $ignore_row = []
  
  attr_accessor :file, :model_name

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  """ 
  Function to set the model name for further processing
  Can be called by the controller to pass model name
  Important to let this same import functionality for all the models
  
  """
  def set_model_name(model_name)
    self.model_name = model_name
  end

  # If there's any error in observation or measurement, then rollback the saved observations
  def rollback
    puts 'rolling back'
    $observation_id_map.keys().each do |k|
      obs = Observation.find($observation_id_map[k])
      obs.destroy!
    end
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
      elsif not item.valid?
        errors.add :base, item.errors.full_messages
        flag = true
      end
    end
    return flag
  end
  
  # Save the unique observation from group of observations in csv
  def save_unique_observations
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)
    $observation_id_map = {}

    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      if not $observation_id_map.keys().include? row["observation_id"] and row["observation_id"].present?
        o = Observation.new(:user_id => row["user_id"], :location_id => row["location_id"], :coral_id => row["coral_id"], :resource_id => row["resource_id"], :approval_status => "pending")
        measurement_row = {"user_id" => row["user_id"],   "trait_id" => row["trait_id"], "standard_id" => row["standard_id"],  "value" => row["value"], "value_type" => row["value_type"], "precision" => row["precision"], "precision_type" => row["precision_type"], "precision_upper" => row["precision_upper"], "replicates" => row["replicates"], "methodology_id" => row["methodology_id"],  "approval_status" => "pending"}
        m = Measurement.new
        m.attributes = measurement_row.to_hash
        o.measurements << m
        
        begin
          o.save!
          $observation_id_map[row["observation_id"]] = o.id
          $ignore_row.append(i)
        rescue => e
          errors.add :base, e
          return false
        end
      end
    end
  end

  

  def save
    $measurements = []
     
    # Save the unique observation from group of observations in csv
    # Do this only if the uploaded csv is a list of observations
    if model_name.to_s == 'Observation'
      observation_error = save_unique_observations
      if not observation_error
        rollback()
        return false
      end    
    end
    

    imp_items = imported_items.compact
    
    # Check for any errors in imported observations
    any_error = check_add_errors(imp_items)
    puts "no error in imported_items"
    # If there's any error, dont override its value
    # If there's no any error, check if error is present in measurements
    if not $measurements.empty?
      any_error ? check_add_errors($measurements) : any_error = check_add_errors($measurements)
    end
    
    # If there is any error, dont attempt to save
    if any_error
      rollback()
      return false
    end    

    
    # If no validation errors, see if there is any mapping error
    # If there is a mapping error, display it and then return
    # If there is no any error, then save it
    #if imported_items.map(&:valid?).all? 

    imp_items.each do |item|
      item.save! if not Observation.all.include? item
    end
    
    # Duplicate Measurements might still cause validation errors.
    begin
      $measurements.each(&:save!)
    rescue => e
      errors.add :base, e
      rollback()
      return false
    end

    true
    
  end

  def imported_items
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)
    @imported_items ||= load_imported_items
  end

  def load_imported_items

    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)
    observation_csv_headers = ["observation_id", "access", "enterer", "coral", "location_name", "latitude", "longitude", "resource_id", "measurement_id", "trait_name", "standard_unit", "value", "value_type", "precision", "precision_type", "precision_upper", "replicates"]
    new_observation_csv_headers = ["observation_id",  "access",  "user_id", "coral_id"  ,"location_id", "resource_id", "trait_id",  "standard_id",  "methodology_id" ,"value" ,"value_type",  "precision" ,"precision_type" , "precision_upper" ,"replicates"]
    
    if header == new_observation_csv_headers
      # Rename some headers to correspond the database fields
      header[header.index("observation_id")] = "id"
      header[header.index("access")] = "private"
      # header[header.index("enterer")] = "user_id"
    
      (2..spreadsheet.last_row).map do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        if $ignore_row.include? i
          next
        end
        
        # Instantiate or find observation and measurement in order to be able to add errors into them
        observation = Observation.find_by_id($observation_id_map[row["id"]])
        #measurement = Measurement.find_by_id(row["measurement_id"]) || Measurement.new
        measurement = Measurement.new
        
        # Start Validations

        # 1. Convert 0 or 1 to true or false for private field
        if row["private"] == "0" or row["private"].empty?
          row["private"] = true
        else
          row["private"] = false
        end
        
        coral_id = row["coral_id"]
        location_id = row["location_id"]
        trait_id = row["trait_id"]
        observation = validate_model_ids(row, observation)
        
        
        # Validate Values based on the traits value range
        begin
          if trait_id
            trait = Trait.find(trait_id)
            if not trait.value_range.include? row["value"] and not trait.value_range.empty?
              observation.errors[:base] << "Invalid Value for the trait: " + row["trait_name"] + ".. Values should be within " + trait.value_range
            end
            # Uncomment this in production
            # $email_list.append(trait.user.email) if ((not $email_list.include? trait.user.email) && trait.user.editor)
          end
          
        rescue
          observation.errors[:base] << "Error with value"
        end
        
        # new_observation_csv_headears = ["observation_id",  "access",  "user_id", "coral_id"  ,"location_id", "resource_id", "trait_id",  "standard_id",  "method_id" ,"value" ,"value_type",  "precision" ,"precision_type" , "precision_upper" ,"replicates"]
        # Create the actual rows to be sent into the database for observation and measurements
        observation_row = {"id" => row["id"], "user_id" => row["user_id"], "location_id" => location_id, "coral_id" => coral_id, "resource_id" => row["resource_id"], "private" => row["private"]}
        measurement_row = {"user_id" => row["user_id"], "observation_id" => $observation_id_map[row["id"]],  "trait_id" => row["trait_id"], "standard_id" => row["standard_id"],  "value" => row["value"], "value_type" => row["value_type"], "precision" => row["precision"], "precision_type" => row["precision_type"], "precision_upper" => row["precision_upper"], "replicates" => row["replicates"], "methodology_id" => row["methodology_id"],  "approval_status" => "pending"}
        
        # Additionally check for any mapping errors
        begin
          observation.attributes = observation_row.to_hash
          measurement.attributes = measurement_row.to_hash
        rescue => error
          observation.errors[:base] << "The column headers do not match with fields..."
          observation.errors[:base] << error.message
          false
        end
        
        #measurement.approval_status = "pending"
        $measurements.append(measurement)
        
        observation.approval_status = "pending"
        # Temporary email list
        $email_list.append("suren.shopushrestha@mq.edu.au")
        observation
      end
    else
      (2..spreadsheet.last_row).map do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        item = model_name.find_by_id(row["id"]) || model_name.new
        
        begin
          item.attributes = row.to_hash
        rescue => error
          item.errors[:base] << "The column headers do not match with fields..."
          item.errors[:base] << error.message
          false
        end
        
        # Validate user_id
        validate_user(item, item.attributes["user_id"])
        
        # Validate latitude
        if item.attributes["latitude"]
          validate_long_lat(item, item.attributes["latitude"], "latitude", -90, 90)
        end
        
        # Validate longitude
        if item.attributes["longitude"]
          validate_long_lat(item, item.attributes["longitude"], "longitude",  -180, 180)
        end

        # Finally return the item
        item.approval_status = "pending"

        $email_list.append("suren.shopushrestha@mq.edu.au")
        item
      end

    end

  end
  
  def get_email_list
    return $email_list.uniq
  end
    
  

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".csv" then Roo::CSV.new(file.path, csv_options: {encoding: Encoding::ISO_8859_1})
    when ".xls" then Roo::Excel.new(file.path)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def validate_user(item, user_id)
    if User.where(id: user_id).empty?
      item.errors[:base] << "Invalid user with id: " + user_id.to_s
    end

  end

  def validate_long_lat(item, val, item_type, start, finish)
    puts "validating #{item_type}"
    val = val.to_i
    if val < start or val > finish
      item.errors[:base] << "Invalid #{item_type}: "  + val.to_s + " ( has to be between #{start} and #{finish} ) "
      puts "latitude error"
    end
  end
  
  def validate_model_ids(row, observation)
    negative_cols = ['methodology_id', 'trait_id']
    row.each do |col|
      if col[0].include? 'id' and col[0].length > 2 and not negative_cols.include? col[0]
        field_name = col[0]
        model_name = field_name.split('_')[0]
        model = model_name.singularize.classify.constantize
        begin
          item = model.find(col[1])
        rescue
          observation.errors[:base] << "Cannot find #{model_name} with that id : " + col[1]
        end

      end
    end

    return observation
  end

end