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
  
  $new_observations = []

  # Map the observation group number in csv spreadsheet to a newly created observation id
  # Format : { '1' : 90613, '2': 90614 }
  $observation_id_map = {}
  
  $email_list = []
  $ignore_row = []
  $total_rows
  $import_type
  $new_observation_csv_headers = ["observation_id",  "access",  "user_id", "specie_id"  ,"location_id", "resource_id", "trait_id",  "standard_id",  "methodology_id" ,"value" ,"value_type",  "precision" ,"precision_type" , "precision_upper" ,"replicates", "notes"]
  attr_accessor :file, :model_name, :current_user

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


  def get_email_list
    return $email_list.uniq
  end
  
  def save(import_type)
    puts 'import_type: ', import_type
    $import_type = import_type

    allowed_file_extensions = ['.csv', '.xls', '.xlsx']
    if not file
      errors.add :base, 'Please Select a File'
      return false
    elsif not allowed_file_extensions.include? File.extname(file.original_filename)
      errors.add :base, 'File Type Not Allowed. Only files of type ' + allowed_file_extensions.to_s + ' are allowed'
      return false
    end


    $measurements = []
     
    # Save the unique observation from group of observations in csv
    # Do this only if the uploaded csv is a list of observations
    if model_name.to_s == 'Observation' and import_type == 'new'
      observation_error = save_unique_observations
      if not observation_error
        rollback()
        return false
      end    
    end
    

    imp_items = imported_items
    
    puts 'Checking for any errors in imported observations'
    # Check for any errors in imported observations
    any_error = check_add_errors(imp_items)
    if not any_error
      puts "no error in imported_items"
    end
    # If there's any error, dont override its value
    # If there's no any error, check if error is present in measurements
    if not $measurements.empty?
      puts 'checking errors for measurements: ' , $measurements
      any_error ? check_add_errors($measurements) : any_error = check_add_errors($measurements)
    end
    
    # If there is any error, dont attempt to save
    if any_error
      rollback()
      return false
    end    

    puts "no error in measurements"
    
    # If no validation errors, see if there is any mapping error
    # If there is a mapping error, display it and then return
    # If there is no any error, then save it
    # if imported_items.map(&:valid?).all? 

    
    
    # Main Code to save the observations 'overwrite / new' begins here
    if $import_type == 'overwrite'
      # First Destroy all the observations and their measurements

      puts "==================================================="
      puts "inspecting new observations"
      puts $new_observations.inspect
      puts "==================================================="
      
      imp_items.compact.each do |item|
        item.save!
      end

      $measurements.each(&:save!)
      

      """
      Observation.update imp_items.uniq.map { |item| item.id }
      
      $new_observations.each do |item|
        puts 'saving new observation'
        puts item.inspect
        puts 'corresponding measurements'
        puts item.measurements.inspect
        item.save!
      end
      """
    else
      imp_items.compact.each do |item|
        item.save!
      end

      # Duplicate Measurements might still cause validation errors.
      begin
        $measurements.each(&:save!)
      rescue => e
        errors.add :base, e
        rollback()
        return false
      end


    end
    

    puts 'All Observations saved.. Saving Measurements now'
    
    
    
    
    # Finally verify if the total number of rows is equal to total records imported
    total_records_imported = Measurement.where('observation_id IN (?)', $observation_id_map.values).count
    if $total_rows -1 != total_records_imported
      err_msg = 'Something went wrong during import. 
                        Total number of records imported is not equal to total number of rows in csv. <br/>
                        Total rows in csv: <b>' +  ($total_rows - 1).to_s + ' </b> <br/>
                        Total records imported: <b>' + (total_records_imported).to_s + '</b>'
      errors.add :base,  err_msg.html_safe
      if $import_type == 'new'
        rollback()
      end
      return false
    end


    true
    
  end
  
  private

    def open_spreadsheet
    
      case File.extname(file.original_filename)
        when ".csv" then Roo::CSV.new(file.path, csv_options: {encoding: Encoding::ISO_8859_1})
        when ".xls" then Roo::Excel.new(file.path)
        when ".xlsx" then Roo::Excelx.new(file.path)
      else raise "Unknown file type: #{file.original_filename}"
      end

    end
    
    # First Check if there is any error in the items in the list
    # If any errors are present, don't attempt to save. Just Return False
    def check_add_errors(items)
      flag = false
      items = items.compact
      items.each_with_index do |item, index|
        
        if item.errors.any?
          item.errors.full_messages.each do |message|
            errors.add :base, "#{message}"
          end
          flag = true
        end
          
        if not item.valid?
          puts 'item not valid: ', item.inspect

          errors.add :base, item.errors.full_messages
          flag = true
        end
      end
      return flag
    end
    
    # If there's any error in observation or measurement, then rollback the saved observations
    def rollback
      puts 'rolling back'
      puts $observation_id_map
      
      # Todo: Make this efficient
      if $import_type != 'new'
        return
      end
      $observation_id_map.keys().each do |k|
        obs = Observation.find($observation_id_map[k])
        obs.destroy!
      end
    end

    # Save the unique observation from group of observations in csv
    def save_unique_observations
      
      spreadsheet = open_spreadsheet
      header = spreadsheet.row(1)
      $observation_id_map = {}
      """
      if header != $new_observation_csv_headers
        errors.add :base, 'The column headers do not match...'
        return false
      end
      """

      (2..spreadsheet.last_row).map do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        puts 'row: ', row
        if not $observation_id_map.keys().include? row["observation_id"] and row["observation_id"].present?
          specie_id = row["specie_id"]
          trait_id = row["trait_id"]
          
          o = Observation.new()
          o, specie_id, trait_id = validate_trait_specie_id_name(row, o, i)

          observation_row = { "user_id" => row["user_id"], "location_id" => row["location_id"], "specie_id" => specie_id, "resource_id" => row["resource_id"], "secondary_id" => row["secondary_id"], "approval_status" => "pending"}
          o.attributes = observation_row.to_hash

          measurement_row = {"user_id" => row["user_id"], "trait_id" => trait_id, "standard_id" => row["standard_id"],  "value" => row["value"], "value_type" => row["value_type"], "precision" => row["precision"], "precision_type" => row["precision_type"], "precision_upper" => row["precision_upper"], "replicates" => row["replicates"], "methodology_id" => row["methodology_id"], "notes" => row["notes"], "approval_status" => "pending"}
          m = Measurement.new
          o = validate_model_ids(row, o, i)
          o = validate_methodology_with_trait(row, o, trait_id, i)

          begin
            puts 'saving unique observations'
            m.attributes = measurement_row.to_hash
            puts "measurement: ", m
            o.measurements << m
            obs_error = check_add_errors([o])
          
            if obs_error
              puts 'validation error while saving unique observation'
              return false
            end

            o.save!
            $observation_id_map[row["observation_id"]] = o.id
            $ignore_row.append(i)
          rescue => e
            puts 'error saving unique observations'
            errors.add :base, e
            return false
          end
        end
      end
    end

    def imported_items
      spreadsheet = open_spreadsheet
      header = spreadsheet.row(1)
      @imported_items ||= load_imported_items
    end

    def load_imported_items
      spreadsheet = open_spreadsheet
      header = spreadsheet.row(1)
      $total_rows = spreadsheet.last_row
      # observation_csv_headers = ["observation_id", "access", "enterer", "specie", "location_name", "latitude", "longitude", "resource_id", "measurement_id", "trait_name", "standard_unit", "value", "value_type", "precision", "precision_type", "precision_upper", "replicates"]
      
      if $import_type == 'new'
        puts 'uploading observations'
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
          puts 'observation found for saving: ', observation.inspect
          #measurement = Measurement.find_by_id(row["measurement_id"]) || Measurement.new
          measurement = Measurement.new
          
          specie_id = row["specie_id"]
          location_id = row["location_id"]
          trait_id = row["trait_id"]

          # Start Validations

          row = process_private(row)
          
          observation = validate_model_ids(row, observation, i)
          observation = validate_trait_id(trait_id, row, observation, i)
          
          observation, specie_id, trait_id = validate_trait_specie_id_name(row, observation, i)
          
          # Validate methodology_id against trait_id
          observation = validate_methodology_with_trait(row, observation, trait_id, i)

          puts 'specie_id : ' , specie_id
          puts 'trait_id: ', trait_id
          
          # Create the actual rows to be sent into the database for observation and measurements
          observation_row = {"id" => $observation_id_map[row["id"]], "user_id" => row["user_id"], "location_id" => location_id, "specie_id" => specie_id, "resource_id" => row["resource_id"], "secondary_id" => row["secondary_id"] , "private" => row["private"]}
          measurement_row = {"user_id" => row["user_id"], "observation_id" => $observation_id_map[row["id"]],  "trait_id" => trait_id, "standard_id" => row["standard_id"],  "value" => row["value"], "value_type" => row["value_type"], "precision" => row["precision"], "precision_type" => row["precision_type"], "precision_upper" => row["precision_upper"], "replicates" => row["replicates"], "methodology_id" => row["methodology_id"], "notes" => row["notes"],  "approval_status" => "pending"}
          
          puts 'measurement_row: ', measurement_row
          # Additionally check for any mapping errors
          begin
            observation.attributes = observation_row.to_hash
            measurement.attributes = measurement_row.to_hash
            # TODO : check if following holds true
            observation.measurements << measurement
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
      elsif $import_type == 'overwrite'
        puts 'overwriting observations'
        # Rename some headers to correspond the database fields
        header[header.index("observation_id")] = "id"
        header[header.index("access")] = "private"
        $observation_id_map = {}
        $new_observations = []
        x = 1
        # header[header.index("enterer")] = "user_id"
      
        (2..spreadsheet.last_row).map do |i|
          row = Hash[[header, spreadsheet.row(i)].transpose]
          
          # Instantiate or find observation and measurement in order to be able to add errors into them
          observation = Observation.find_by_id(row["id"])
          
          if not $observation_id_map.values().include? row["id"]
            $observation_id_map[x] = row["id"]
            obs_new =  Observation.new
            x = x + 1
            
          else
            obs_new = $new_observations[$observation_id_map.values().index(row['id'])]
            
          end

          puts 'observation found for saving: ', observation.inspect
          measurement = Measurement.find_by_id(row["measurement_id"]) || Measurement.new
          puts 'measurement found: ', measurement.inspect
          #measurement = Measurement.new
          
          # Check if the signed in user is the owner of the observation
          puts 'current_user: ' + current_user.id.to_s
          puts 'user_id : ' + row['user_id'].to_s
          if current_user.id.to_s != row['user_id'] and not current_user.admin?
            observation.errors[:base] << "Row #{i} : Only owner of the observation or admin can overwrite "
            observation
          end


          specie_id = row["specie_id"]
          location_id = row["location_id"]
          trait_id = row["trait_id"]
          
          # Start Validations

          row = process_private(row)

          observation = validate_model_ids(row, observation, i)
          
          observation = validate_trait_id(trait_id, row, observation, i)
          # Validate methodology_id against trait_id

          observation = validate_methodology_with_trait(row, observation, trait_id, i)
          
          
          # new_observation_csv_headears = ["observation_id",  "access",  "user_id", "specie_id"  ,"location_id", "resource_id", "trait_id",  "standard_id",  "method_id" ,"value" ,"value_type",  "precision" ,"precision_type" , "precision_upper" ,"replicates"]
          # Create the actual rows to be sent into the database for observation and measurements
          observation_row = {"id" => row["id"], "user_id" => row["user_id"], "location_id" => location_id, "specie_id" => specie_id, "resource_id" => row["resource_id"], "secondary_id" => row["secondary_id"] , "private" => row["private"]}
          measurement_row = {"id" => measurement.id, "user_id" => row["user_id"],  "trait_id" => row["trait_id"], "standard_id" => row["standard_id"],  "value" => row["value"], "value_type" => row["value_type"], "precision" => row["precision"], "precision_type" => row["precision_type"], "precision_upper" => row["precision_upper"], "replicates" => row["replicates"], "methodology_id" => row["methodology_id"], "notes" => row["notes"],  "approval_status" => "pending"}
          
          puts 'measurement_row: ', measurement_row
          # Additionally check for any mapping errors
          begin
            observation.attributes = observation_row.to_hash
            measurement.attributes = measurement_row.to_hash
            obs_new.attributes = observation_row.to_hash
            obs_new.measurements << measurement
          rescue => error
            observation.errors[:base] << "The column headers do not match with fields..."
            observation.errors[:base] << error.message
            false
          end


          
          #measurement.approval_status = "pending"
          $measurements.append(measurement)
          $new_observations.append(obs_new)
          
          observation.approval_status = "pending"
          # Temporary email list
          $email_list.append("suren.shopushrestha@mq.edu.au")
          puts 'sending back observation: ' , observation.inspect
          observation
        end
      elsif model_name.to_s != 'Observation'
        puts 'uploading non observations'
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
          validate_user(item, item.attributes["user_id"], i)
          
          # Validate latitude
          if item.attributes["latitude"]
            validate_long_lat(item, item.attributes["latitude"], "latitude", -90, 90, i)
          end
          
          # Validate longitude
          if item.attributes["longitude"]
            validate_long_lat(item, item.attributes["longitude"], "longitude",  -180, 180, i)
          end

          # Finally return the item
          item.approval_status = "pending"

          $email_list.append("suren.shopushrestha@mq.edu.au")
          item
        end

      end

    end
    
    # Validations of values in the fields in csv

    def process_private(row)
      # 1. Convert 0 or 1 to true or false for private field
      if row["private"] == "0" or row["private"].empty?
        row["private"] = true
      else
        row["private"] = false
      end

      return row
    end

    def validate_trait_id(trait_id, row, observation, i)
      # Validate Values based on the traits value range
      begin
        if trait_id
          trait = Trait.find(trait_id)
         if not trait.value_range.nil? and trait.value_range == "" 
            if not trait.value_range.include? row["value"] and not trait.value_range.empty?
              observation.errors[:base] << "Row #{i}: Invalid Value for the trait: " + row["trait_name"] + ".. Values should be within " + trait.value_range
            end
          end
          # Uncomment this in production
          # $email_list.append(trait.user.email) if ((not $email_list.include? trait.user.email) && trait.user.editor)
        end
        
      rescue
        observation.errors[:base] << "Row #{i}: Error with value"
      end

      return observation
    end

    def validate_trait_specie_id_name(row, observation, i)
      begin
        trait_id = row['trait_id']
        trait_name = row['trait_name']
        specie_id = row['specie_id']
        specie_name = row['specie_name']
        puts 'trait_id', trait_id
        puts 'trait_name ', trait_name

        if trait_id and trait_name
          puts 'both trait_id and trait_name'
          trait = Trait.find(trait_id)
          if trait_name.strip.downcase != trait.trait_name.strip.downcase
            puts 'trait_id,  trait_name MISMATCH'
            observation.errors[:base] << "Row #{i}: Trait_id and Trait_name do not match"

          end
        elsif trait_name and not trait_id
          traits = Trait.where("lower(trait_name)  IS ?", trait_name.strip.downcase)
          puts 'only trait_name'
          puts traits.count
          if traits.count == 0
            puts 'no trait with that trait_name'
            observation.errors[:base] << "Row #{i}: Trait with corresponding Trait_name not found in database"
            trait_id = nil
          else
            puts 'trait found with trait_name'
            trait_id = traits[0].id
          end
        end

        if specie_id and specie_name
          specie = Specie.find(specie_id)
          puts 'both specie_id and specie_name'
          if specie_name.strip.downcase != specie.specie_name.strip.downcase
            puts ' specie_id and specie_name MISMATCH'
            observation.errors[:base] << "Row #{i}: Specie_id and Specie_name do not match"

          end
        elsif specie_name and not specie_id
          species = Specie.where("lower(specie_name)  IS ?", specie_name.strip.downcase)
          puts 'only specie_name'
          if species.count == 0
            puts 'specie_name error'
            observation.errors[:base] << "Row #{i}: Species with corresponding Specie_name not found in database"
            specie_id = nil
          else
            specie_id  = species[0].id
          end
        end
      rescue => e
        observation.errors[:base] << e

      end
      puts 'trait id name validation: ', trait_id
      return observation, specie_id, trait_id
    end
  
    def validate_user(item, user_id, i)
      if User.where(id: user_id).empty?
        item.errors[:base] << "Row #{i}: Invalid user with id: " + user_id.to_s
      end

    end

    def validate_long_lat(item, val, item_type, start, finish, i)
      puts "validating #{item_type}"
      val = val.to_i
      if val < start or val > finish
        item.errors[:base] << "Row #{i}: Invalid #{item_type}: "  + val.to_s + " ( has to be between #{start} and #{finish} ) "
        puts "latitude error"
      end
    end
    
    def validate_model_ids(row, observation, i)
      negative_cols = ['observation_id', 'trait_id', 'measurement_id']
      row.each do |col|
        if col[0].include? 'id' and col[0].length > 2 and not negative_cols.include? col[0]
          field_name = col[0]
          model_name = field_name.split('_')[0]
          model = model_name.singularize.classify.constantize
          puts 'trying to validate model'
          begin
            item = model.find(col[1]) if not col[1].nil?
          rescue
            puts 'in validate_model_ids, cant find model with that id'
            observation.errors[:base] << "Row #{i}: Cannot find #{model_name} with that id : " + col[1]
          end

        end
      end

      return observation
    end

    def validate_methodology_with_trait(row, observation, trait_id, i)
      puts 'trait_id : ', trait_id
      if not row["methodology_id"].nil? and row["methodology_id"] != ""
        
        if not Trait.find(trait_id).methodology_ids.include?  row["methodology_id"].to_i

        
          observation.errors[:base] << "Row #{i}: Trait with id : #{ row["trait_id"]}  doesnot have methodology with id : #{row["methodology_id"]} " 
        else
          puts "no error, trait: ", row["trait_id"], " methodology: ", row["methodology_id"]
        end
      else
        puts "methodology is not present"
      end

      return observation
    end


end
