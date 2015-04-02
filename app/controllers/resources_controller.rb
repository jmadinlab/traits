class ResourcesController < ApplicationController

  before_action :contributor, except: [:index, :show, :export]
  before_action :admin_user, only: [:destroy, :status]
  before_action :set_resource, only: [:show, :edit, :update, :destroy]

  def index

    @search = Resource.search do
      fulltext params[:search]
      order_by :author_sortable, :asc
      
      if params[:all]
        paginate page: params[:page], per_page: 9999
      else
        paginate page: params[:page]
      end
    end
    @resources = @search.results

    respond_to do |format|
      format.html
      format.csv { send_data Resource.all.to_csv }
    end    
  end

  def status

    @resources = Resource.where("author like ?", "%.%").paginate(:page=> params[:page], :per_page => 20)

    respond_to do |format|
      format.html
      format.csv { send_data Resource.all.to_csv }
    end    
  end

  def show

    @primary = Observation.where('resource_id = ?', @resource.id)
    @secondary = Observation.where('resource_secondary_id = ?', @resource.id)

    @primary = observation_filter(@primary)
    @secondary = observation_filter(@secondary)

    respond_to do |format|
      format.html {
        @primary = @primary.paginate(:page=> params[:page], :per_page => 20)
        @secondary = @secondary.paginate(:page=> params[:page], :per_page => 20)
      }
      format.csv { download_observations(@primary, params[:taxonomy], params[:contextual] || "on", params[:global]) }
      format.zip{ send_zip(@primary, params[:taxonomy], params[:contextual] || "on", params[:global]) }
    end

  end

  # GET /resources/new
  def new
    @resource = Resource.new
  end

  # GET /resources/1/edit
  def edit
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(resource_params)

    if @resource.save
      redirect_to @resource, flash: {success: "Resource was successfully created." }
    else
      render action: 'new' 
    end
  end

  # PATCH/PUT /resources/1
  # PATCH/PUT /resources/1.json
  def update
    if @resource.update(resource_params)
      redirect_to @resource, flash: {success: "Resource was successfully updated." }
    else
      render action: 'edit'
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resource.destroy
    respond_to do |format|
      format.html { redirect_to resources_url }
      format.json { head :no_content }
    end
  end

  def export
    @observations = Observation.where(:resource_id => params[:checked])
    @observations = observation_filter(@observations)

    send_zip(@observations, params[:taxonomy], params[:contextual], params[:global])                   
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = Resource.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      params.require(:resource).permit(:author, :year, :title, :resource_type, :doi_isbn, :journal, :volume_pages, :pdf_name, :resource_notes, :approval_status, :user_id)
    end

end
