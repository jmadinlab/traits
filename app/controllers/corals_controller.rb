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
    
    if params[:id]
      @coral = Coral.find(params[:id])
    end


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
    
        send_data csv_string, 
          :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
          :disposition => "attachment; filename=coral_#{Date.today.strftime('%Y%m%d')}.csv"

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

  # method for versioning
  def history
    @versions = PaperTrail::Version.order('created_at DESC')

    
  end

  def history_csv
    @version = PaperTrail::Version.find_by_id(params[:version_id])
    @coral = @version.reify
    
    show()
  end

  def revert_back
    #@version = PaperTrail::Version.find_by_id(params[:id])
    @version = PaperTrail::Version.find_by_id(params[:version_id])
    begin
      if @version.reify
        # revert back to any action (update, destroy )
        @version.reify.save
      else
        # revert back for create action
        @version.item.destroy
      end
      flash[:success] = ' Successfully Reverted back to the version'

    rescue
      flash[:alert] = 'Revert Failed'
    ensure 
      redirect_to root_path
    end

  end

  # Create revert back link for version history
  def make_revert_link(coral_id)
    @coral = Coral.find_by_id(coral_id)
    #view_context.link_to 'Revert Back', revert_back_path(@coral.versions.last), method: :post
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
