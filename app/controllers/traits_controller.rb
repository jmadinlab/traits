class TraitsController < ApplicationController
  before_action :signed_in_user
  before_action :contributor, except: [:index, :show, :export]
  before_action :set_trait, only: [:show, :edit, :update, :destroy]
  before_action :admin_user, only: :destroy

  # GET /traits
  # GET /traits.json
  def index
    @traits = Trait.search(params[:search])

    respond_to do |format|
      format.html
      format.csv { send_data @traits.to_csv }
    end    
  end

  def export
      
    if signed_in? && current_user.contributor?
      if current_user.admin?
        @observations = Observation.joins{measurements}.where{measurements.trait_id.in my{params[:checked]}}  
      else
        @observations = Observation.where{ (private == 'f') | ((user_id == my{current_user.id}) & (private == 't')) }.        
          joins{measurements}.where{measurements.trait_id.in my{params[:checked]}}
      end
    else
      @observations = Observation.where{ (private == 'f') }.
        joins{measurements}.where{measurements.trait_id.in my{params[:checked]}}        
    end        
    
    csv_string = CSV.generate do |csv|
      csv << ["observation_id", "access", "enterer", "coral", "location_name", "latitude", "longitude", "resource_id", "measurement_id", "trait_name", "standard_unit", "value", "precision", "precision_type", "precision_upper", "replicates"]
      @observations.each do |obs|
        if params[:global].blank? || obs.location_id == 1
          obs.measurements.each do |mea|
            if !params[:ancillary].blank? | params[:checked].include?(mea.trait_id.to_s)
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
        
      end
    end

    send_data csv_string, 
      :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
      :disposition => "attachment; filename=ctdb_#{Date.today.strftime('%Y%m%d')}.csv"
          
  end

  # GET /traits/1
  # GET /traits/1.json
  def show
    @files = Dir.glob("app/assets/images/traits/*")

    if params[:n].blank?
      params[:n] = 100
    end
    
    n = params[:n]
    
    if params[:n] == "all"
      n = 9999999
    end

    if signed_in? && current_user.contributor?
      if current_user.admin?
        @observations = Observation.includes(:coral).
          joins{measurements}.where{(measurements.value =~ my{"%#{params[:search]}%"}) & (measurements.trait_id == my{@trait.id})}.limit(n) |
          Observation.includes(:coral).
          joins{measurements.trait}.where{(measurements.traits.trait_name =~ my{"%#{params[:search]}%"}) & (measurements.trait_id == my{@trait.id})}.limit(n)
		  else
        @observations = Observation.where{ (private == 'f') | ((user_id == my{current_user.id}) & (private == 't')) }.includes(:coral).
          joins{measurements}.where{(measurements.value =~ my{"%#{params[:search]}%"}) & (measurements.trait_id == my{@trait.id})}.limit(n) |
          Observation.where{ (private == 'f') | ((user_id == my{current_user.id}) & (private == 't')) }.includes(:coral).          
          joins{measurements.trait}.where{(measurements.traits.trait_name =~ my{"%#{params[:search]}%"}) & (measurements.trait_id == my{@trait.id})}.limit(n)
      end
    else
      @observations = Observation.where{ private == 'f' }.includes(:coral).
        joins{measurements}.where{(measurements.value =~ my{"%#{params[:search]}%"}) & (measurements.trait_id == my{@trait.id})}.limit(n) |
        Observation.where{ private == 'f' }.includes(:coral).          
        joins{measurements.trait}.where{(measurements.traits.trait_name =~ my{"%#{params[:search]}%"}) & (measurements.trait_id == my{@trait.id})}.limit(n)
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
          :disposition => "attachment; filename=trait_#{Date.today.strftime('%Y%m%d')}.csv"

        }
    end

  end

  # GET /traits/new
  def new
    @trait = Trait.new
  end

  # GET /traits/1/edit
  def edit
  end

  # POST /traits
  # POST /traits.json
  def create
    @trait = Trait.new(trait_params)

    if @trait.save
      redirect_to @trait, flash: {success: "Trait was successfully created." }
    else
      render action: 'new' 
    end
  end

  # PATCH/PUT /traits/1
  # PATCH/PUT /traits/1.json
  def update
    if @trait.update(trait_params)
      redirect_to @trait, flash: {success: "Trait was successfully updated." }
    else
      render action: 'edit'
    end
  end

  # DELETE /traits/1
  # DELETE /traits/1.json
  def destroy
    @trait.destroy
    respond_to do |format|
      format.html { redirect_to traits_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trait
      @trait = Trait.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trait_params
      params.require(:trait).permit(:trait_name, :trait_description, :trait_class, :value_range, :standard_id, :user_id)
    end
end


