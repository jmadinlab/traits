class ResourcesController < ApplicationController
  # before_action :signed_in_user
  before_action :contributor, except: [:index, :show, :export]
  before_action :set_resource, only: [:show, :edit, :update, :destroy]
  before_action :admin_user, only: :destroy

  helper_method :sort_column, :sort_direction

  # GET /resources
  # GET /resources.json
  def index
    @resources = Resource.order(sort_column + " " + sort_direction).search(params[:search])
    # @resources = @resources.paginate(page: params[:page])
    
    respond_to do |format|
      format.html
      format.csv { send_data @resources.to_csv }
    end    
  end

  # GET /resources/1
  # GET /resources/1.json
  def show

    if params[:n].blank?
      params[:n] = 10
    end
    
    n = params[:n]
    
    if params[:n] == "all"
      n = 9999999
    end

    if !signed_in? | (signed_in? && (!current_user.admin? | !current_user.contributor?))
    @observations = Observation.where(['observations.resource_id IS ? AND observations.private IS ?', @resource.id, false]).includes(:coral).joins(:measurements).where('value LIKE ?', "%#{params[:search]}%").uniq.limit(n)
    end
    
    if signed_in? && current_user.contributor?
      @observations = Observation.where(['observations.resource_id IS ? AND (observations.private IS ? OR (observations.user_id IS ? AND observations.private IS ?))', @resource.id, false, current_user.id, true]).includes(:coral).joins(:measurements).where('value LIKE ?', "%#{params[:search]}%").uniq.limit(n)
    end

    if signed_in? && current_user.admin?
      @observations = Observation.where(:resource_id => @resource.id).includes(:coral).joins(:measurements).where('value LIKE ?', "%#{params[:search]}%").uniq.limit(n)
    end
    
    respond_to do |format|
      format.html
      format.csv { 
        if request.url.include? 'resources.csv'
          csv_string = get_resources_csv(@observations)
          filename = 'resources_extra.csv'
        else
          csv_string = get_main_csv(@observations)
          filename = 'resources_main.csv'
        end
        
        send_data csv_string, 
          :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
          :disposition => "attachment; filename=#{filename}_#{Date.today.strftime('%Y%m%d')}.csv"
      }

      format.zip{
        send_zip(@observations, 'resources.csv')
      }
    end

    # if signed_in?
    #   if current_user.admin?
    #         @observations = Observation.find(:all, :conditions => ["resource_id=?", @resource.id])
    #       else
    #     @observations = Observation.find(:all, :conditions => ["resource_id=? AND (private=? OR (user_id=? AND private=?))", @resource.id, false, current_user.id, true])
    #   end
    # else
    #   @observations = Observation.find(:all, :conditions => ["resource_id=? AND private=?", @resource.id, false])
    #   flash[:success] = "You are not signed in. You will only see publicly accessable data."
    # end
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = Resource.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      params.require(:resource).permit(:author, :year, :title, :resource_type, :doi_isbn, :journal, :volume_pages, :pdf_name, :resource_notes, :approval_status)
    end

    def sort_column
      Resource.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

end
