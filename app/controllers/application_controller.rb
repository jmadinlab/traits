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
    redirect_to(root_url) unless (current_user?(@user) || current_user.admin?)
  end

  def admin_user
      redirect_to(root_url) unless signed_in? && current_user.admin?
  end

  def contributor
      redirect_to(
        root_url,flash: {danger: "You need to be a contributor to access this area of the database." }
      ) unless (signed_in? && (current_user.contributor? || current_user.admin?))  
  end

  def editor
      redirect_to(
        root_url,flash: {danger: "You need to be a editor to access this area of the database." }
      ) unless (signed_in? && (current_user.editor? || current_user.admin?))      
  end

  def enterer
    @observation = Observation.find(params[:id]) if params[:id]
    if @observation
      redirect_to(
        root_url, flash: { danger: "You can't edit or delete other peoples' observations." }
      ) unless (signed_in? && ((@observation.user_id == current_user.id) || current_user.admin?))      
    else
      redirect_to(
        root_url, flash: { danger: "You need to become a contributor to enter data." }
      ) unless (signed_in? && current_user.contributor?)
    end
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
  def get_main_csv(observations, taxonomy, contextual, global)
    csv_string = CSV.generate do |csv|
      if taxonomy == "on"
        csv << ["observation_id", "access", "user_id", "coral_id", "coral_name", "major_clade", "family_molecules", "family_morphology", "location_id", "location_name", "latitude", "longitude", "resource_id", "measurement_id", "trait_id", "trait_name", "standard_id", "standard_unit", "methodology_id", "methodology_name", "value", "value_type", "precision", "precision_type", "precision_upper", "replicates", "notes"]
      else
        csv << ["observation_id", "access", "user_id", "coral_id", "coral_name", "location_id", "location_name", "latitude", "longitude", "resource_id", "measurement_id", "trait_id", "trait_name", "standard_id", "standard_unit", "methodology_id", "methodology_name", "value", "value_type", "precision", "precision_type", "precision_upper", "replicates", "notes"]
      end
      observations.each do |obs|
        if global != "on" || obs.location_id == 1
          obs.measurements.each do |mea|
            if (contextual != nil && contextual != "off") || mea.trait.trait_class != "Contextual"
              if obs.location.present?
                loc = obs.location.location_name
                lat = obs.location.latitude
                lon = obs.location.longitude
                if obs.location.id == 1
                  lat = nil
                  lon = nil
                end
              else
                loc = nil
                lat = nil
                lon = nil
              end
              if obs.private == true
                acc = 0
              else
                acc = 1
              end

              method = nil
              if mea.methodology.present?
                method = mea.methodology.methodology_name
              end
              if taxonomy == "on"
                csv << [obs.id, acc, obs.user_id, obs.coral.id, obs.coral.coral_name, obs.coral.major_clade, obs.coral.family_molecules, obs.coral.family_morphology, obs.location_id, loc, lat, lon, obs.resource_id, mea.id, mea.trait.id, mea.trait.trait_name, mea.standard.id, mea.standard.standard_unit, mea.methodology_id, method, mea.value, mea.value_type, mea.precision, mea.precision_type, mea.precision_upper, mea.replicates, mea.notes]
              else
                csv << [obs.id, acc, obs.user_id, obs.coral.id, obs.coral.coral_name, obs.location_id, loc, lat, lon, obs.resource_id, mea.id, mea.trait.id, mea.trait.trait_name, mea.standard.id, mea.standard.standard_unit, mea.methodology_id, method, mea.value, mea.value_type, mea.precision, mea.precision_type, mea.precision_upper, mea.replicates, mea.notes]
              end
            end
          end
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
  def send_zip(observations, file_name='file1.csv', taxonomy, contextual, global)
    require 'rubygems'
    require 'zip'

    # Process file1 (corals.csv, traits.csv, locations.csv)
    csv_string = get_main_csv(observations, taxonomy, contextual, global)
    file1 = file_name
    file1_path = "public/" + file1
    _file1 = File.open(file1_path, "w") { |f| f << csv_string }
    

    # Process file2 resources.csv
    resources_string = get_resources_csv(observations)
    file2 = "resources.csv"
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
      :disposition => "attachment; filename = ctdb.zip"
    end
    File.delete(zipfile_name)
    FileUtils.rm_f(file2_path)
    FileUtils.rm_f(file1_path)

  end

  
  def upload_csv
    @name = params[:controller]  
  end


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
