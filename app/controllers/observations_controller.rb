class ObservationsController < ApplicationController
  before_action :signed_in_user
  before_action :contributor
  before_action :set_observation, only: [:show, :edit, :update, :destroy]

  # autocomplete :location, :name, :full => true
  # autocomplete :coral, :name, :full => true
  # autocomplete :resource, :author, :full => true, :extra_data => [:year], :display_value => :resource_fill


  def update_values
      @temp_var = 0
      @values = Trait.find(params[:trait_id]).value_range.split(',').map(&:strip)
      @standard = Standard.find(Trait.find(params[:trait_id]).standard_id)
      @element_id = params[:element_id].split("trait_select")[-1]
      puts 'trait id '
      puts params[:trait_id]

  end

  def edit_multiple
    @observations = Observation.find(params[:obs_ids])
  end

  def update_multiple

    Observation.where(:user_id => params[:con_id], :id => params[:all_ids]).update_all(:private => false)
    Observation.where(:user_id => params[:con_id], :id => params[:pri_ids]).update_all(:private => true)
    
    # flash[:notice] = "Updated observations!"
    redirect_to user_path(params[:con_id], :page => @page, :search => @search), flash: {success: "Privacy updated." }
  end

  # GET /observations
  # GET /observations.json
  def index

    if params[:n].blank?
      params[:n] = 10
    end
    
    n = params[:n]
    
    if params[:n] == "all"
      n = 9999999
    end

    if !signed_in? | (signed_in? && (!current_user.admin? | !current_user.contributor?))
      @observations = Observation.where(['observations.private IS ?', false]).includes(:coral).joins(:measurements).where('measurements.value LIKE ?', "%#{params[:search]}%").limit(n)
    end
    
    if signed_in? && current_user.contributor?
      @observations = Observation.where(['observations.private IS ? OR (observations.user_id IS ? AND observations.private IS ?)', false, current_user.id, true]).includes(:coral).joins(:measurements).where('measurements.value LIKE ?', "%#{params[:search]}%").limit(n)
    end

    if signed_in? && current_user.admin?
      @observations = Observation.includes(:coral).joins(:measurements).where('measurements.value LIKE ?', "%#{params[:search]}%").limit(n)
    end

    
    respond_to do |format|
      format.html
      format.csv { 
        csv_string = get_main_csv(@observations)
        send_data csv_string, 
          :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
          :disposition => "attachment; filename=observations_#{Date.today.strftime('%Y%m%d')}.csv"

        }
    end
  end

  # GET /observations/1
  # GET /observations/1.json
  def show
  end

  # GET /observations/new
  def new
    @observation = Observation.new
    @values = ""
    @temp_var = 0
  end

  # GET /observations/1/edit
  def edit
    @temp_var = 0
    if (@observation.user_id != current_user.id) & !current_user.admin?
      flash[:danger] = 'You need to be the original contributor of an observation to edit it.'
      if params[:user].blank?
        if params[:trait].blank?
          redirect_to coral_path(@observation.coral_id)
        else
          redirect_to trait_path(params[:trait])
        end
      else
        redirect_to user_path(@observation.user_id)
      end
    end
    @values = ""
  end

  # POST /observations
  # POST /observations.json
  def create
    @observation = Observation.new(observation_params)
    @observation.measurements.each do |mea|
      mea.orig_value = mea.value
    end
    
    if @observation.save
      redirect_to @observation, flash: {success: "Observation was successfully created." }
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /observations/1
  # PATCH/PUT /observations/1.json
  def update
    @temp_var = 0    
    @observation.measurements.each do |mea|
      if mea.orig_value.blank?
        mea.orig_value = mea.value
      end
    end
    
      if @observation.update(observation_params)
        redirect_to @observation, flash: {success: "Observation was successfully updated." }
      else
        render action: 'edit'
      end
  end

  # DELETE /observations/1
  # DELETE /observations/1.json
  def destroy
    if @observation.user_id == current_user.id
      @observation.destroy
      flash[:success] = 'Observation was successfully deleted.'
      if params[:user].blank?
        if params[:trait].blank?
          redirect_to coral_path(@observation.coral_id)
        else
          redirect_to trait_path(params[:trait])
        end
      else
        redirect_to user_path(@observation.user_id)
      end

    else
      flash[:danger] = 'Observation NOT deleted. You need to be the original contributor of an observation to delete it.'
      if params[:user].blank?
        if params[:trait].blank?
          redirect_to coral_path(@observation.coral_id)
        else
          redirect_to trait_path(params[:trait])
        end
      else
        redirect_to user_path(@observation.user_id)
      end
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_observation
      @observation = Observation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def observation_params
      params.require(:observation).permit(:user_id, :location_id, :coral_id, :resource_id, :private, measurements_attributes: [:id, :user_id, :orig_user_id, :trait_id, :standard_id, :value, :orig_value, :precision_type, :precision, :precision_upper, :replicates, :notes, :_destroy])
    end
end
