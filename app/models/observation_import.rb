class ObservationImport
  extend ActiveModel::Model
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :file, :import_type

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end


  def save
    puts "IMPORT: #{import_type}".red

    # valid file
    allowed_file_extensions = ['.csv', '.xls', '.xlsx']
    if not file
      errors.add :base, 'Please select a file'
      return false
    elsif not allowed_file_extensions.include? File.extname(file.original_filename)
      errors.add :base, 'Only files of type ' + allowed_file_extensions.to_s + ' are allowed'
      return false
    end

    any_error = check_add_errors(imported_observations)

    if any_error
      false
    else
      imported_observations.each(&:save!)
      if import_type == "overwrite"
        Measurement.where(:id => $remove).destroy_all
        puts "MEASUREMENTS REMOVED WITH OVERWRITE: #{$remove}".red
      end
      true
    end
  end

  def imported_observations
    @imported_observations ||= load_imported_observations
  end

  def load_imported_observations
    spreadsheet = open_spreadsheet

    # Get header and change a few header names to match database
    header = spreadsheet.row(1)
    puts "header: #{header}".red

    required_headers = ["observation_id", "access", "user_id", "location_id", "resource_id", "standard_id", "methodology_id", "value", "value_type", "precision", "precision_type", "precision_upper", "replicates", "notes"]

    required_flag = true
        puts "FLAG: #{required_flag}".red
    required_headers.each do |r|
      if not header.include? r
        errors.add :base, "Missing header for #{r}"
        required_flag = false
      end
    end

    if not header.include? "specie_name" and not header.include? "specie_id"
      errors.add :base, "Missing header for either specie_id or specie_name"
      required_flag = false
    end

    if not header.include? "trait_name" and not header.include? "trait_id"
      errors.add :base, "Missing header for either trait_id or trait_name"
      required_flag = false
    end
    
    if required_flag == false
      return false
    else

      header[header.index("observation_id")] = "id"
      header[header.index("access")] = "private"

      if import_type == "overwrite"
        # Make list of measurement ids to remove (if overwrite)
        $remove = spreadsheet.column(1)
        $remove.shift
        $remove = Measurement.where(:observation_id => $remove).map(&:id)
        puts "=== remove measurements: #{$remove}".red

      end

      observation_marker = "-1"
      (2..spreadsheet.last_row).map do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        row = process_private(row)

        if row["specie_name"]
          specie = Specie.where("specie_name = ?", row["specie_name"])
          puts "=== Specie: #{specie.inspect}".red
          if specie.empty?
            errors[:base] << "Row #{i}: Species name '#{row["specie_name"]}' does not exist"
          else
            if not row["specie_id"] or row["specie_id"].blank?
              row["specie_id"] = specie.first.id
            elsif specie.first.id != row["specie_id"].to_i
              errors[:base] << "Row #{i}: Species name '#{row["specie_name"]}' does not match species_id=#{specie.first.id}"
            end
          end
        end
        if row["trait_name"]
          trait = Trait.where("trait_name = ?", row["trait_name"])
          puts "=== Trait: #{trait.inspect}".red
          if trait.empty?
            errors[:base] << "Row #{i}: Measurement trait name does not exist"
          else
            if not row["trait_id"] or row["trait_id"].blank?
              row["trait_id"] = trait.first.id
            elsif trait.first.id != row["trait_id"].to_i
              errors[:base] << "Row #{i}: Trait name '#{row["trait_name"]}' does not match trait_id=#{trait.first.id}"
            end
          end
        end


        # puts "#{row["specie_id"].inspect}".blue
        # puts "#{Observation.where("specie_id IS ?", row["specie_id"]).inspect}".blue

        if observation_marker != row["id"]
          if import_type == "overwrite"
            $observation = Observation.find_by_id(row["id"])
            puts "=== #{$observation.inspect}".red
            if $observation.nil?
              $observation = Observation.new
              if row["id"].blank?
                $observation.errors[:base] << "Row #{i}: Observation id is empty"
              else
                $observation.errors[:base] << "Row #{i}: Observation with id=#{row["id"]} doesn't exist"
              end
            end
          else
            $observation = Observation.new
            if row["id"].blank?
              $observation.errors[:base] << "Row #{i}: Observation id is empty"
            end
          end

          observation_row = {"id" => $observation.id, "user_id" => row["user_id"], "location_id" => row["location_id"], "specie_id" => row["specie_id"], "resource_id" => row["resource_id"], "resource_secondary_id" => row["resource_secondary_id"] , "private" => row["private"]}
          $observation.attributes = observation_row.to_hash
          $observation.approval_status = "pending"

          observation_marker = row["id"]
        else
          $observation = validate_observation_consistency(i, row)
        end

        $observation = validate_observation_exist(i, row)

        measurement = $observation.measurements.build

        measurement_row = {"observation_id" => $observation.id, "user_id" => row["user_id"],  "trait_id" => row["trait_id"], "standard_id" => row["standard_id"],  "value" => row["value"], "value_type" => row["value_type"], "precision" => row["precision"], "precision_type" => row["precision_type"], "precision_upper" => row["precision_upper"], "replicates" => row["replicates"], "methodology_id" => row["methodology_id"], "notes" => row["notes"],  "approval_status" => "pending"}

        measurement.attributes = measurement_row.to_hash

        $observation = validate_measurement_exist(i, row)

        puts "==== #{measurement.inspect}".red

        $observation
      end
    end
  end

  def open_spreadsheet
    case File.extname(file.original_filename)
    # when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
    when ".csv" then Roo::CSV.new(file.path, csv_options: {encoding: Encoding::ISO_8859_1})
    when ".xls" then Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  private

    def validate_measurement_exist(i, row)
      if row["trait_id"].blank?
        $observation.errors[:base] << "Row #{i}: Trait_id is blank"
      elsif Trait.where("id = ?", row["trait_id"]).blank?
        $observation.errors[:base] << "Row #{i}: Trait with id=#{row["trait_id"]} doesn't exist"
      end
      if row["standard_id"].blank?
        $observation.errors[:base] << "Row #{i}: standard_id is blank"
      elsif Standard.where("id = ?", row["standard_id"]).blank?
        $observation.errors[:base] << "Row #{i}: Standard with id=#{row["standard_id"]} doesn't exist"
      end
      if row["methodology_id"].blank?
      elsif Methodology.where("id = ?", row["methodology_id"]).blank?
        $observation.errors[:base] << "Row #{i}: Methodology with id=#{row["methodology_id"]} doesn't exist"
      end
      if row["value"].blank?
        $observation.errors[:base] << "Row #{i}: Value is blank"
      end
      if row["value_type"].blank?
        $observation.errors[:base] << "Row #{i}: Value_type is blank"
      elsif !['raw_value', 'mean', 'median', 'maximum', 'minimum', 'model_derived', 'expert_opinion' , 'group_opinion'].include? row["value_type"]
        $observation.errors[:base] << "Row #{i}: Value_type=#{row["value_type"]} doesn't match allowed value types"
      end
      if row["precision_type"].blank?
      elsif !['standard_error', 'standard_deviation', '95_ci', 'range'].include? row["precision_type"]
        $observation.errors[:base] << "Row #{i}: Precision_type=#{row["precision_type"]} doesn't match allowed precision types"
      end
      return $observation
    end

    def validate_observation_consistency(i, row)
      $observation.errors[:base] << "Row #{i}: Access should be same for all measurements" if $observation.private != row["private"]
      $observation.errors[:base] << "Row #{i}: User_id should be same for all measurements" if $observation.user_id != row["user_id"].to_i
      $observation.errors[:base] << "Row #{i}: Specie_id should be same for all measurements" if $observation.specie_id != row["specie_id"].to_i
      $observation.errors[:base] << "Row #{i}: Location_id should be same for all measurements" if $observation.location_id != row["location_id"].to_i
      $observation.errors[:base] << "Row #{i}: Resource_id should be same for all measurements" if $observation.resource_id != row["resource_id"].to_i
      return $observation
    end

    def validate_observation_exist(i, row)
      $observation.errors[:base] << "Row #{i}: User_id=#{row["user_id"]} doesn't exist" if User.where("id = ?", row["user_id"]).blank?
      $observation.errors[:base] << "Row #{i}: Specie_id=#{row["specie_id"]} doesn't exist" if Specie.where("id = ?", row["specie_id"]).blank?
      $observation.errors[:base] << "Row #{i}: Location_id=#{row["location_id"]} doesn't exist" if Location.where("id = ?", row["location_id"]).blank?
      $observation.errors[:base] << "Row #{i}: Resource_id=#{row["resource_id"]} doesn't exist" if Resource.where("id = ?", row["resource_id"]).blank?
      return $observation
    end

    def process_private(row)
      # 1. Convert 0 or 1 to true or false for private field
      if row["private"] == "0" or row["private"].empty?
        row["private"] = true
      else
        row["private"] = false
      end

      return row
    end

    def check_add_errors(items)
      flag = false
      if items.present?
        items = items.compact
        items.each_with_index do |item, index|    
          if item.errors.any?
            item.errors.full_messages.each do |message|
              errors.add :base, "#{message}"
            end
            flag = true
          end
            
          # if not item.valid?
          #   item.errors.full_messages.each do |message|
          #     errors.add :base, "Row #{index+2} v: #{message}"
          #   end
          #   flag = true
          # end
        end
      else
        flag = true
      end
      return flag
    end

end