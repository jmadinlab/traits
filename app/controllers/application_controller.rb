class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  
  WillPaginate.per_page = 30

  before_filter :set_last_seen_at, if: proc { |p| signed_in? && (session[:last_seen_at] == nil || session[:last_seen_at] < 15.minutes.ago) }

  def update_values
    @values = Trait.find(params[:trait_id]).value_range.split(',').map(&:strip)
    @standard = Standard.find(Trait.find(params[:trait_id]).standard_id)
  end
  
  # Before filters

  def observation_filter(observations)
    if signed_in?
      if current_user.admin?
        observations = observations
      elsif current_user.editor? | current_user.contributor?
        observations = observations.where("observations.private = ? OR (observations.user_id = ? AND observations.private = ?)", false, current_user.id, true)
      else
        observations = observations.where("observations.private = ?", false)
      end
    else
      observations = observations.where("observations.private = ?", false)
    end
    observations
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url, flash: {danger: "You can't access other user pages." }) unless (current_user?(@user) || current_user.admin?)
  end

  def admin_user
      redirect_to(root_url) unless signed_in? && current_user.admin?
  end

  def contributor
      redirect_to(
        root_url, flash: {danger: "You need to be a contributor to access this area of the database." }
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

  # Return the main csv string depending upon the model (species data / traits data / lcation data etc)

  def download_observations(observations, taxonomy=nil, contextual=nil, global=nil)

    if request.url.include? 'resources.csv'
      csv_string = get_resources_csv(@observations)
      filename = 'resources'
    else
      csv_string = get_main_csv(@observations, taxonomy, contextual, global)
      filename = 'data'
    end
    send_data csv_string, 
      :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
      :disposition => "attachment; filename=#{filename}_#{Date.today.strftime('%Y%m%d')}.csv"
  end

  def get_main_csv(observations, taxonomy=nil, contextual=nil, global=nil)
    csv_string = CSV.generate do |csv|
      if taxonomy == "on"
        csv << ["observation_id", "access", "user_id", "specie_id", "specie_name", "major_clade", "family_molecules", "family_morphology", "location_id", "location_name", "latitude", "longitude", "resource_id", "measurement_id", "trait_id", "trait_name", "standard_id", "standard_unit", "methodology_id", "methodology_name", "value", "value_type", "precision", "precision_type", "precision_upper", "replicates", "notes"]
      else
        csv << ["observation_id", "access", "user_id", "specie_id", "specie_name", "location_id", "location_name", "latitude", "longitude", "resource_id", "measurement_id", "trait_id", "trait_name", "standard_id", "standard_unit", "methodology_id", "methodology_name", "value", "value_type", "precision", "precision_type", "precision_upper", "replicates", "notes"]
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
                csv << [obs.id, acc, obs.user_id, obs.specie.id, obs.specie.specie_name, obs.specie.major_clade, obs.specie.family_molecules, obs.specie.family_morphology, obs.location_id, loc, lat, lon, obs.resource_id, mea.id, mea.trait.id, mea.trait.trait_name, mea.standard.id, mea.standard.standard_unit, mea.methodology_id, method, mea.value, mea.value_type, mea.precision, mea.precision_type, mea.precision_upper, mea.replicates, mea.notes]
              else
                csv << [obs.id, acc, obs.user_id, obs.specie.id, obs.specie.specie_name, obs.location_id, loc, lat, lon, obs.resource_id, mea.id, mea.trait.id, mea.trait.trait_name, mea.standard.id, mea.standard.standard_unit, mea.methodology_id, method, mea.value, mea.value_type, mea.precision, mea.precision_type, mea.precision_upper, mea.replicates, mea.notes]
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
  def send_zip(observations, taxonomy=nil, contextual=nil, global=nil)
    require 'rubygems'
    require 'zip'

    # Process file1 (species.csv, traits.csv, locations.csv)
    data_string = get_main_csv(observations, taxonomy, contextual, global)
    data_file_path = "public/data.csv"
    _file1 = File.open(data_file_path, "w") { |f| f << data_string }
    
    # Process file2 resources.csv
    resources_string = get_resources_csv(observations)
    resource_file_path = "public/resources.csv"
    _file2 = File.open(resource_file_path, "w") { |f| f << resources_string }
    
    # Combine file1 and file2 into zip file
    zipfile_name = 'zippedfiles.zip'
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      zipfile.add("data.csv", data_file_path)
      zipfile.add("resources.csv", resource_file_path)
    end

    File.open(zipfile_name, 'r') do |f|
      send_data f.read, type: "application/zip", :stream => true,
      :disposition => "attachment; filename = ctdb.zip"
    end
    File.delete(zipfile_name)
    FileUtils.rm_f(data_file_path)
    FileUtils.rm_f(resource_file_path)

  end

  
  def upload_csv
    @name = params[:controller]  
  end



  private

    def set_last_seen_at
      current_user.update_attribute(:last_seen_at, Time.now)
      session[:last_seen_at] = Time.now
    end

  
end
