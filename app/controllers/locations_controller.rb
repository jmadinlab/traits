class LocationsController < ApplicationController
  # before_action :signed_in_user
  before_action :contributor, except: [:index, :show, :export]
  before_action :set_location, only: [:show, :edit, :update, :destroy]
  before_action :admin_user, only: :destroy

  helper_method :sort_column, :sort_direction

  # GET /locations
  # GET /locations.json
  def index

    @search = Location.search do
      fulltext params[:search]
      order_by :location_name_sortable, :asc
      
      if params[:all]
        paginate page: params[:page], per_page: 9999
      else
        paginate page: params[:page]
      end
    end
    @locations = @search.results

    respond_to do |format|
      format.html
      format.csv { send_data Location.all.to_csv }
    end    

  end

  def export
    if params[:checked]
      @observations = Observation.where(:location_id => params[:checked])
      @observations = observation_filter(@observations)
    else
      @observations = []
    end

    send_zip(@observations, params[:taxonomy], params[:contextual], params[:global])                   
  end


  # GET /locations/1
  # GET /locations/1.json
  def show

    @observations = Observation.where('location_id = ?', @location.id)
    @observations = observation_filter(@observations)

    respond_to do |format|
      format.html { @observations = @observations.paginate(page: params[:page]) }
      format.csv { download_observations(@observations, params[:taxonomy], params[:contextual] || "on", params[:global]) }
      format.zip{ send_zip(@observations, params[:taxonomy], params[:contextual] || "on", params[:global]) }
    end
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
      params.require(:location).permit(:location_name, :latitude, :longitude, :location_description, :user_id, :approval_status)
    end
    
    def sort_column
      Location.column_names.include?(params[:sort]) ? params[:sort] : "location_name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
