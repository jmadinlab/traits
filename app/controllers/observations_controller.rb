 class ObservationsController < ApplicationController

  # before_action :contributor, only: [:new, :create ]
  before_action :enterer, except: [:show]
  # before_action :enterer, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_observation, only: [:show, :edit, :update, :destroy]
  # before_action :admin, :destroy

  # autocomplete :location, :name, :full => true
  # autocomplete :specie, :name, :full => true
  # autocomplete :resource, :author, :full => true, :extra_data => [:year], :display_value => :resource_fill

  def import
    Observation.import(params[:file])
    redirect_to root_url, notice: "Observation imported."
  end

  def update_values
    @values = Trait.find(params[:trait_id]).traitvalues.map(&:id)
    @standard = Standard.find(Trait.find(params[:trait_id]).standard_id)
    @element_id = params[:element_id]
    @element_id.slice! "_trait_id"
    @element_id.to_s
    # @methodologies = Trait.find(params[:trait_id]).methodologies
    #meas = Measurement.find(params[:measurement_id]) if params[:measurement_id] != ""
    #puts 'printing form obs controller'
    #puts meas.value
    #meas.value = ""
  end

  def edit_multiple
    @observations = Observation.find(params[:obs_ids])
  end

  def update_multiple
    Observation.where(:user_id => params[:con_id], :id => params[:all_ids]).update_all(:private => false)
    Observation.where(:user_id => params[:con_id], :id => params[:pri_ids]).update_all(:private => true)
    # flash[:notice] = "Updated observations!"
    puts "============ HERE ================"
    puts params[:location]
    redirect_to user_path(params[:con_id], :page => @page, :search => @search, :resource => params[:resource], :location => params[:location], :specie => params[:specie], :trait => params[:trait]), flash: {success: "Privacy updated." }
  end

  # GET /observations
  # GET /observations.json
  def index

    @search = Observation.search do
      fulltext params[:search]
      (with :private, false or with :user_id, current_user.id) unless signed_in? && current_user.admin?

      if params[:all]
        paginate page: params[:page], per_page: 2000
      else
        paginate page: params[:page]
      end
    end

    @observations = @search.results
    
    respond_to do |format|
      format.html

      format.csv {
        if request.url.include? 'resources.csv'
          csv_string = get_resources_csv(@observations)
          filename = 'resources'
        else
          csv_string = get_main_csv(@observations, "", "", "")
          filename = 'data'
        end

        send_data csv_string, 
          :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
          :disposition => "attachment; filename=#{filename}_#{Date.today.strftime('%Y%m%d')}.csv"
      }

      format.zip{
        send_zip(@observations, 'data.csv', "", "")
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
  end

  # GET /observations/1/edit
  def edit
    if (@observation.user_id != current_user.id) & !current_user.admin?
      flash[:danger] = 'You need to be the original contributor of an observation to edit it.'
      if params[:user].blank?
        if params[:trait].blank?
          redirect_to specie_path(@observation.specie_id)
        else
          redirect_to trait_path(params[:trait])
        end
      else
        redirect_to user_path(@observation.user_id)
      end
    end
  end

  # POST /observations
  # POST /observations.json
  def create
    @observation = Observation.new(observation_params)
    @observation.approval_status = "pending"
    @observation.measurements.each do |mea|
      mea.orig_value = mea.value
      mea.approval_status = "pending"
    end
    
    if @observation.save
      # Todo: Uncomment following line in production
      #UploadApprovalMailer.approve(current_user).deliver
      redirect_to @observation, flash: {success: "Observation was successfully created." }
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /observations/1
  # PATCH/PUT /observations/1.json
  def update
    @observation.measurements.each do |mea|
      if mea.orig_value.blank?
        mea.orig_value = mea.value
        
      end
      mea.approval_status = "pending"
    end
    
      if @observation.update(observation_params)
        # Todo: Uncomment following line in production
        #UploadApprovalMailer.approve(current_user).deliver
        redirect_to @observation, flash: {success: "Observation was successfully updated." }
      else
        render action: 'edit'
      end
  end

  # DELETE /observations/1
  # DELETE /observations/1.json
  def destroy
    if (@observation.user_id == current_user.id) | current_user.admin?
      @observation.destroy
      flash[:success] = 'Observation was successfully deleted.'
      redirect_to user_path(current_user.id)
    else
      flash[:danger] = 'Observation NOT deleted. You need to be the original contributor of an observation to delete it.'
      if params[:user].blank?
        if params[:trait].blank?
          redirect_to specie_path(@observation.specie_id)
        else
          redirect_to trait_path(params[:trait])
        end
      else
        redirect_to user_path(@observation.user_id)
      end
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.90157
    def set_observation

      @observation = Observation.find(params[:id])
      if @observation.private == true 
        if !signed_in? | (signed_in? && @observation.user_id != current_user.id && !current_user.admin?)
            redirect_to( root_url, flash: {danger: "You need to be a contributor to access this area of the database." } )
        end
      end

    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def observation_params
      params.require(:observation).permit(:user_id, :location_id, :specie_id, :resource_id, :private, :approval_status, :resource_secondary_id, measurements_attributes: [:id, :user_id, :orig_user_id, :trait_id, :standard_id, :value, :value_type, :orig_value, :precision_type, :precision, :precision_upper, :replicates, :notes, :methodology_id, :approval_status, :_destroy])
    end


end
