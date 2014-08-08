class ResourcesController < ApplicationController
  # before_action :signed_in_user
  before_action :contributor, except: [:index, :show, :export]
  before_action :set_resource, only: [:show, :edit, :update, :destroy]
  before_action :admin_user, only: :destroy

  # GET /resources
  # GET /resources.json
  def index

    pp = 15
    pp = 9999 if params[:pp]

    @search = Resource.search do
      fulltext params[:search]
      paginate page: params[:page], per_page: pp
    end
    
    if params[:search]
      @resources = @search.results
    else
      @resources = Resource.all.paginate(:page=> params[:page], :per_page => pp)
    end


    # @resources = @resources.sort_by{|l| l[:id]} if params[:sort] == "id"
    # @resources = @resources.sort_by{|l| l[:author]} if params[:sort] == "author"
    # @resources = @resources.sort_by{|l| l[:year] || 0 } if params[:sort] == "year"
    # @resources = @resources.sort_by{|l| l[:title]} if params[:sort] == "title"
    # @resources = @resources.reverse if params[:order] == "descending"

    respond_to do |format|
      format.html
      format.csv { send_data Resource.all.to_csv }
    end    
  end

  # GET /resources/1
  # GET /resources/1.json
  def show

    @observations = Observation.where('resource_id IS ?', @resource.id)

    if signed_in? && current_user.admin?
    elsif signed_in? && current_user.editor?
    elsif signed_in? && current_user.contributor?
      @observations = @observations.where(['observations.private IS ? OR (observations.user_id IS ? AND observations.private IS ?)', false, current_user.id, true])
    else
      @observations = @observations.where(['observations.private IS ?', false])
    end

    respond_to do |format|
      format.html {
        @observations = @observations.paginate(:page=> params[:page], :per_page => 20)
      }
      format.csv {
        if request.url.include? 'resources.csv'
          csv_string = get_resources_csv(@observations, "", "")
          filename = 'resources'
        else
          csv_string = get_main_csv(@observations, "", "")
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
    checked = params[:checked]
      
    if signed_in? && current_user.contributor?
      if current_user.admin?
        #@observations = Observation.where{location_id.in my{params[:checked]}}
        @observations = Observation.where(:resource_id => params[:checked])
      else
        #@observations = Observation.where{ (private == 'f') | ((user_id == my{current_user.id}) & (private == 't')) }.        
        #where{location_id.in my{params[:checked]}}
        @observations = Observation.where(" (private = 'f' or (private = 't' and user_id = ? )) ", current_user.id).where(:resource_id => params[:checked])

      end
    else
      @observations = Observation.where(:private => false).where(:resource_id => params[:checked])        
    end        
    
    send_zip(@observations, 'traits.csv', params[:taxonomy], params[:contextual], params[:global])
          
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
