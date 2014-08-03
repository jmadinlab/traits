class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  WillPaginate.per_page = 15

  def update_values
    @values = Trait.find(params[:trait_id]).value_range.split(',').map(&:strip)
    @standard = Standard.find(Trait.find(params[:trait_id]).standard_id)
  end
  
  # Before filters

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
      redirect_to(root_url) unless signed_in? && current_user.admin?
  end

  def contributor
      redirect_to(
        root_url,flash: {danger: "You need to be a contributor to access this area of the database." }
      ) unless (signed_in? && (current_user.contributor? || current_user.admin?))
      
  end

  # get ip of the user for versioning database
  def info_for_paper_trail
    # Save additional info
    { ip: request.remote_ip }
  end

  def user_for_paper_trail
    # Save the user responsible for the action
    signed_in? ? current_user.id : 'Guest'
  end

  # Return the main csv string depending upon the model (corals data / traits data / lcation data etc)
  def get_main_csv(observations)
      csv_string = CSV.generate do |csv|
          csv << ["observation_id", "access", "enterer", "coral", "location_name", "latitude", "longitude", "resource_id", "measurement_id", "trait_name", "methodology_name", "standard_unit",  "value", "precision", "precision_type", "precision_upper", "replicates"]
          observations.each do |obs|
            obs.measurements.each do |mea|
              if obs.location.present?
                loc = obs.location.location_name
                lat = obs.location.latitude
                lon = obs.location.longitude
                if obs.location.id == 1
                  lat = ""
                  lon = ""
                end
              else
                loc = ""
                lat = ""
                lon = ""
              end
              if obs.private == true
                acc = 0
              else
                acc = 1
              end

              method = ""
              if mea.methodology.present?
                method = mea.methodology.methodology_name
              end

              csv << [obs.id, acc, obs.user_id, obs.coral.coral_name, loc, lat, lon, obs.resource_id, mea.id, mea.trait.trait_name, method, mea.standard.standard_unit, mea.value, mea.precision, mea.precision_type, mea.precision_upper, mea.replicates]
            end
          end
        end
    
     return csv_string
    end



  # Return the resources csv
  def get_resources_csv(observations)
    resources_string = CSV.generate do |csv|
        csv << ["resource_id", "author", "year", "title", "resource_type", "resource_ISBN", "resource_journal", "resource_volume_pages", "resource_notes"]

        Resource.where(:id => observations.map(&:resource).uniq).each do |res|
          # if obs.resource
            # res = obs.resource
            res_id = res.id
            res_author = res.author
            res_year = res.year
            res_title = res.title
            res_type = res.resource_type
            res_isbn = res.doi_isbn
            res_journal = res.journal
            res_volume = res.volume_pages
            res_notes = res.resource_notes

            csv << [res_id, res_author, res_year, res_title, res_type, res_isbn, res_journal, res_volume, res_notes]
          # end
        end
      end

    return resources_string
  end


  # Return the zip file
  def send_zip(observations, file_name='file1.csv')
    require 'rubygems'
    require 'zip'

    # Process file1 (corals.csv, traits.csv, locations.csv)
    csv_string = get_main_csv(observations)
    file1 = file_name
    file1_path = "public/" + file1
    _file1 = File.open(file1_path, "w") { |f| f << csv_string }
    

    # Process file2 resources.csv
    resources_string = get_resources_csv(observations)
    file2 = "resources_file.csv"
    file2_path = "public/" + file2
    _file2 = File.open(file2_path, "w") { |f| f << resources_string }
    
    # Combine file1 and file2 into zip file
    zipfile_name = 'zippedfiles.zip'
    folder = 'public'
    input_filenames = [file1, file2]
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      input_filenames.each do |filename|
        zipfile.add(filename, folder + "/" + filename)
      end
    end

    
    File.open(zipfile_name, 'r') do |f|
      send_data f.read, type: "application/zip", :stream => true,
      :disposition => "attachment; filename = zippedfile.zip"
    end
    File.delete(zipfile_name)
    FileUtils.rm_f(file2_path)
    FileUtils.rm_f(file1_path)

  end

  
  def upload_csv
    @name = params[:controller]  
  end

  # create_table "corals", force: true do |t|
  #   t.string   "coral_name"
  #   t.text     "coral_description"
  #   t.integer  "user_id"
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.string   "approval_status"
  #   t.string   "major_clade"
  #   t.string   "family_molecules"
  #   t.string   "family_morphology"
  # end

    # t.integer  "coral_id"
    # t.string   "synonym_name"
    # t.text     "synonym_notes"
    # t.datetime "created_at"
    # t.datetime "updated_at"

  def get_coral_csv(corals)
      csv_string = CSV.generate do |csv|
          csv << ["coral_id", "master_species", "major_clade", "family_molecules", "family_morphology", "synonym_species", "coral_notes"]
          corals.each do |cor|
            syn_vec = []
            cor.synonyms.each do |syn|
              syn_vec << syn.synonym_name
            end
            csv << [cor.id, cor.coral_name, cor.major_clade, cor.family_molecules, cor.family_morphology, syn_vec.join(", "), cor.coral_description]
          end
        end
    
     return csv_string
    end

  
end
