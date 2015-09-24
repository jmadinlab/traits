 class ObservationsController < ApplicationController

  # before_action :contributor, only: [:new, :create ]
  before_action :enterer, except: [:show, :count]
  # before_action :enterer, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_observation, only: [:show, :edit, :update, :destroy]
  # before_action :admin, :destroy

  # autocomplete :location, :name, :full => true
  # autocomplete :specie, :name, :full => true
  # autocomplete :resource, :author, :full => true, :extra_data => [:year], :display_value => :resource_fill

  def count

    @model1 = params[:model1].singularize
    if params[:model2]
      puts "HERE".green
      @model2 = params[:model2].singularize
      if @model1 == "specie" and @model2 == "trait"
       @observations = Observation.joins(:measurements).where("specie_id = ? AND trait_id = ?", params[:itemid1], params[:itemid2])
      end
      if @model1 == "trait" and @model2 == "resource"
       @observations = Observation.joins(:measurements).where("trait_id = ? AND resource_id = ?", params[:itemid1], params[:itemid2])
      end
    else
      if @model1 == "trait" or @model1 == "standard" or @model1 == "methodology"
        @observations = Observation.where(:id => Measurement.where("#{@model1}_id = ?", params[:itemid1]).map(&:observation_id))
      elsif @model1 == "user"
        @observations = Observation.where("observations.#{@model1}_id = ?", params[:itemid1])
      else
        @observations = Observation.where("#{@model1}_id = ?", params[:itemid1])
      end
    end

    @observations = observation_filter(@observations)

    render json: {
      pub: @observations.where(:private => false).size, 
      pri: @observations.where(:private => true).size
    }    
  end

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
    @user = User.where(:id => params[:con_id]).first
    Observation.where(:user_id => params[:con_id], :id => params[:all_ids]).update_all(:private => true)

    if params[:pub_ids]
      puts params[:pub_ids].size
      fails = []
      params[:pub_ids].each do |pub|
        puts "=============================================================="
        puts pub
        puts "=============================================================="

        @observation = Observation.where(:user_id => params[:con_id], :id => pub).first
        if @observation.resource
          puts "=======================YESYESYESY=============================="
          @observation.update(:private => false)
        else
          puts "=======================NONONONONO=============================="
          fails << "#{pub}"
          # flash: {success: "Cannot make observation_id=#{pub} public, because no resource." }
        end

        if !fails.empty?
          flash[:danger] = "Observation/s #{fails.join(", ")} cannot be made public because they do not have a resource."
        end

      end

    end

    # flash[:notice] = "Updated observations!"
    puts "============ HERE ================"
    puts params[:location]
    redirect_to user_path(@user, :page => @page, :search => @search, :resource => params[:resource], :location => params[:location], :specie => params[:specie], :trait => params[:trait]), flash: {success: "Privacy updated." }
  end

  # GET /observations
  # GET /observations.json
  def index

    puts "#{current_user.id}".green

    @search = Observation.search do
      fulltext params[:search]
      # (with :private, false or with :user_id, current_user.id)

      any_of do
        with(:private, false) unless signed_in? && current_user.admin?
        with(:user_id, current_user.id) unless signed_in? && current_user.admin?
      end

      paginate page: params[:page]
    end

    @observations = @search.results
    # @observations = observation_filter(@observations)

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

    # puts @observation.resource_doi
    
    # if params[:resource_doi]
    #   resource = Resource.where(:doi_isbn => params[:resource_doi])
    #   if resource.present?
    #     @observation.resource_id = resource.first.id
    #     puts "----- WAS present =============================="
    #   else
    #     puts "----- WAS NOT present =============================="
    #     begin
    #       @doi = JSON.load(open("https://api.crossref.org/works/#{params[:resource_doi]}"))
    #       if @doi["message"]["author"][0]["family"] == "Peresson"
    #         @doi = "Invalid"
    #       end
    #     rescue
    #       @doi = "Invalid"
    #     end
    #     puts @doi

    #     if not @doi == "Invalid"


    #       @resource = Resource.new(resource_params)

    #       authors = ""
    #       @doi["message"]["author"].each do |a|
    #         authors = authors + "#{a["family"].titleize}, #{a["given"].titleize}, "
    #       end

    #       @resource.author = authors
    #       @resource.year = @doi["message"]["issued"]["date-parts"][0][0]
    #       @resource.title = @doi["message"]["title"][0]
    #       @resource.journal = @doi["message"]["container-title"][0]
    #       @resource.volume_pages = @doi["message"]["volume"], @doi["message"]["page"]
    #       @resource.save!

    #       if @resource.save
    #         @observation.resource_id = @resource.id
    #       else
    #         @observation.errors.add(:base, 'The oid was invalid')
    #       end
    #     else
    #       @observation.errors.add(:base, 'The oid was invalid')
    #     end
    #   end
    # end

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
      redirect_to traits_path
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
