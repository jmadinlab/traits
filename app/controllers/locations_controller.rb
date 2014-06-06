class LocationsController < ApplicationController
  # before_action :signed_in_user
  before_action :contributor, except: [:index, :show, :export]
  before_action :set_location, only: [:show, :edit, :update, :destroy]
  before_action :admin_user, only: :destroy

  helper_method :sort_column, :sort_direction

  # GET /locations
  # GET /locations.json
  def index
    @locations = Location.order(sort_column + " " + sort_direction).search(params[:search])
    # @locations = @locations.paginate(page: params[:page])

    respond_to do |format|
      format.html
      format.csv { send_data @locations.to_csv }
    end    

  end

  def export
    checked = params[:checked]
      
    if signed_in? && current_user.contributor?
      if current_user.admin?
        #@observations = Observation.where{location_id.in my{params[:checked]}}
        @observations = Observation.where(:location_id => params[:checked])
      else
        #@observations = Observation.where{ (private == 'f') | ((user_id == my{current_user.id}) & (private == 't')) }.        
        #where{location_id.in my{params[:checked]}}
        @observations = Observation.where(" (private = 'f' or (private = 't' and user_id = ? )) ", current_user.id).where(:location_id => params[:checked])

      end
    else
      @observations = Observation.where(:private => false).where(:location_id => params[:checked])        
    end        
    
    csv_string = get_main_csv(@observations)

    send_data csv_string, 
      :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
      :disposition => "attachment; filename=ctdb_#{Date.today.strftime('%Y%m%d')}.csv"
          
  end

  # GET /locations/1
  # GET /locations/1.json
  def show

    if params[:n].blank?
      params[:n] = 10
    end
    
    n = params[:n]
    
    if params[:n] == "all"
      n = 9999999
    end

    if !signed_in? | (signed_in? && (!current_user.admin? | !current_user.contributor?))
    @observations = Observation.where(['observations.location_id IS ? AND observations.private IS ?', @location.id, false]).includes(:coral).joins(:measurements).where('value LIKE ?', "%#{params[:search]}%").limit(n)
    end
    
    if signed_in? && current_user.contributor?
      @observations = Observation.where(['observations.location_id IS ? AND (observations.private IS ? OR (observations.user_id IS ? AND observations.private IS ?))', @location.id, false, current_user.id, true]).includes(:coral).joins(:measurements).where('value LIKE ?', "%#{params[:search]}%").limit(n)
    end

    if signed_in? && current_user.admin?
      @observations = Observation.where(:location_id => @location.id).includes(:coral).joins(:measurements).where('value LIKE ?', "%#{params[:search]}%").limit(n)
    end


    respond_to do |format|
      format.html
      format.csv { 

        if request.url.include? 'resources.csv'
          csv_string = get_resources_csv(@observations)
          filename = 'resources.csv'
        else
          csv_string = get_main_csv(@observations)
          filename = 'locations.csv'
        end
        
        send_data csv_string, 
          :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
          :disposition => "attachment; filename=#{filename}_#{Date.today.strftime('%Y%m%d')}.csv"

        }

        format.zip{
          send_zip(@observations, 'locations.csv')
        }
    end




    # 
    # 
    # 
    # 
    # if signed_in?
    #   if current_user.admin?
    #     # @observations = Observation.find(:all, :conditions => ["location_id=?", @location.id])
    #         @observations = Observation.includes(:coral, :resource, :location, :user).where("location_id=?", @location.id)
    #     # @measurements = Measurement.includes(:trait, :standard).where("observation_id=?", grp.id)
    #       else
    #     @observations = Observation.find(:all, :conditions => ["location_id=? AND (private=? OR (user_id=? AND private=?))", @location.id, false, current_user.id, true])
    #   end
    # else
    #   @observations = Observation.find(:all, :conditions => ["location_id=? AND private=?", @location.id, false])
    #   flash[:success] = "You are not signed in. You will only see publicly accessable data."
    # end
  end

  # GET /locations/new
  def new
    @location = Location.new
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations
  # POST /locations.json
  def create
    @location = Location.new(location_params)

    if @location.save
      redirect_to locations_path, flash: {success: "Location was successfully created." }
    else
      render action: 'new' 
    end
  end

  # PATCH/PUT /locations/1
  # PATCH/PUT /locations/1.json
  def update
    if @location.update(location_params)
      redirect_to @location, flash: {success: "Location was successfully updated." }
    else
      render action: 'edit'
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @location.destroy
      redirect_to locations_url, flash: {success: "Location was successfully deleted." }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_params
      params.require(:location).permit(:location_name, :latitude, :longitude, :location_description, :user_id)
    end
    
    def sort_column
      Location.column_names.include?(params[:sort]) ? params[:sort] : "location_name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
