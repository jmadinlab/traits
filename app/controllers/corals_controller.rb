class CoralsController < ApplicationController

  before_action :contributor, except: [:index, :show, :export]
  before_action :set_coral, only: [:show, :edit, :update, :destroy]
  before_action :admin_user, only: :destroy

  # GET /corals
  # GET /corals.json
  def index
    @corals = Coral.search(params[:search])
    
    respond_to do |format|
      format.html
      format.csv { send_data @corals.to_csv }
    end    
  end

  def export
    checked = params[:checked]


    if !signed_in? | (signed_in? && (!current_user.admin? | !current_user.contributor?))
      @observations = Observation.where(:private => false).where(:coral_id => params[:checked])        
    end
    
    if signed_in? && current_user.contributor?
      @observations = Observation.where(['observations.private IS ? OR (observations.user_id IS ? AND observations.private IS ?)', false, current_user.id, true]).where(:coral_id => params[:checked])
    end

    if signed_in? && current_user.admin?
      @observations = Observation.where(:coral_id => params[:checked])        
    end
        
    csv_string = CSV.generate do |csv|
      csv << ["observation_id", "access", "enterer", "coral", "location_name", "latitude", "longitude", "resource_id", "measurement_id", "trait_name", "standard_unit", "value", "precision", "precision_type", "precision_upper", "replicates"]
      @observations.each do |obs|
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
          csv << [obs.id, acc, obs.user_id, obs.coral.coral_name, loc, lat, lon, obs.resource_id, mea.id, mea.trait.trait_name, mea.standard.standard_unit, mea.value, mea.precision, mea.precision_type, mea.precision_upper, mea.replicates]
        end
      end
    end

    send_data csv_string, 
      :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
      :disposition => "attachment; filename=ctdb_#{Date.today.strftime('%Y%m%d')}.csv"
          
  end

  # GET /corals/1
  # GET /corals/1.json
  def show
    @vfiles = Dir.glob("app/assets/images/veron/*")
    @hfiles = Dir.glob("app/assets/images/hughes/*")
    
    @coral = @item if @item
    @coral = Coral.find(params[:id]) if params[:id]
    



    if !signed_in? | (signed_in? && (!current_user.admin? | !current_user.contributor?))
      #@observations = Observation.where(['observations.coral_id IS ? AND observations.private IS ?', @coral.id, false])
      # just a better approach to find active `
      @observations = @coral.observations.where(private: false)
    end
    
    if signed_in? && current_user.contributor?
      @observations = Observation.where(['observations.coral_id IS ? AND (observations.private IS ? OR (observations.user_id IS ? AND observations.private IS ?))', @coral.id, false, current_user.id, true])
    end

    if signed_in? && current_user.admin?
      @observations = Observation.where(:coral_id => @coral.id)
    end

    respond_to do |format|
      format.html
      format.csv {
        csv_string = CSV.generate do |csv|
          csv << ["observation_id", "access", "enterer", "coral", "location_name", "latitude", "longitude", "resource_id", "measurement_id", "trait_name", "standard_unit", "value", "precision", "precision_type", "precision_upper", "replicates"]
          @observations.each do |obs|
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
              csv << [obs.id, acc, obs.user_id, obs.coral.coral_name, loc, lat, lon, obs.resource_id, mea.id, mea.trait.trait_name, mea.standard.standard_unit, mea.value, mea.precision, mea.precision_type, mea.precision_upper, mea.replicates]
            end
          end
        end
    
        
        #send_data csv_string, 
        #  :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
        #  :disposition => "attachment; filename=coral_#{Date.today.strftime('%Y%m%d')}.csv"


        file1 = "corals_file.csv"
        file1_path = "public/" + file1
        #FileUtils.rm_f(file1_path)
        _file1 = File.open(file1_path, "w") { |f| f << csv_string }
        

        

        resources_string = CSV.generate do |csv|
          csv << ["observation_id", "enterer", "coral", "Resource ID", "Author", "Year", "Title", "Resource Type", "Resource ISBN", "Resource Journal", "Resource Volume Pages", "Resource Notes"]
          @observations.each do |obs|
            if obs.resource
              res = obs.resource
              res_id = obs.resource.id
              res_author = res.author
              res_year = res.year
              res_title = res.title
              res_type = res.resource_type
              res_isbn = res.doi_isbn
              res_journal = res.journal
              res_volume = res.volume_pages
              res_notes = res.resource_notes

              csv << [obs.id, obs.user_id, obs.coral.coral_name, res_id, res_author, res_year, res_title, res_type, res_isbn, res_journal, res_volume, res_notes]
            end
          end
        end
        
    
        #send_data resources_string, 
        #  :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
        #  :disposition => "attachment; filename=resource_#{Date.today.strftime('%Y%m%d')}.csv"


        file2 = "resources_file.csv"
        file2_path = "public/" + file2
        #File.delete(file2_path) if File.exist?(file2_path)
        #FileUtils.rm_f(file2_path)
        _file2 = File.open(file2_path, "w") { |f| f << resources_string }
        


        require 'rubygems'
        require 'zip'

        zipfile_name = 'zippedfiles.zip'
        #FileUtils.rm_f(zipfile_name)

        folder = 'public'
        input_filenames = [file1, file2]
        Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
          input_filenames.each do |filename|
            zipfile.add(filename, folder + "/" + filename)
          end

          #zipfile.get_output_stream("myfile") { |os| os.write "myfile contains just hits" }

        end

        #_file1.close()

        #_file2.close()

        File.open(zipfile_name, 'r') do |f|
          send_data f.read, type: "application/zip", :stream => true,
          :disposition => "attachment; filename = 'zippedfile.zip'"
        end
        File.delete(zipfile_name)
        FileUtils.rm_f(file2_path)
        FileUtils.rm_f(file1_path)
        


        }
    end
  end

  # GET /corals/new
  def new
    @coral = Coral.new
  end

  # GET /corals/1/edit
  def edit
  end

  # POST /corals
  # POST /corals.json
  def create
    @coral = Coral.new(coral_params)

    if @coral.save
      redirect_to @coral, flash: {success: "Coral was successfully created." }
    else
      render action: 'new' 
    end
  end

  # PATCH/PUT /corals/1
  # PATCH/PUT /corals/1.json
  def update
    if @coral.update(coral_params)
      redirect_to @coral, flash: {success: "Coral was successfully updated." }
    else
      render action: 'edit'
    end
  end

  # DELETE /corals/1
  # DELETE /corals/1.json
  def destroy
    @coral.destroy
    respond_to do |format|
      format.html { redirect_to corals_url }
      format.json { head :no_content }
    end
  end




  private
    # Use callbacks to share common setup or constraints between actions.
    def set_coral
      @coral = Coral.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def coral_params
      params.require(:coral).permit(:coral_name, :coral_description, :user_id)
    end

    
end
