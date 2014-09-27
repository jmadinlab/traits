class CoralsController < ApplicationController

  before_action :contributor, except: [:index, :show, :export]
  before_action :set_coral, only: [:show, :edit, :update, :destroy]
  before_action :admin_user, only: [:destroy, :new, :create, :edit, :update]

  # GET /corals
  # GET /corals.json
  def index
    # @corals = Coral.search(params[:search])

    pp = 15
    pp = 9999 if params[:pp]
    
    @search = Coral.search do
      fulltext params[:search]
      paginate page: params[:page], per_page: pp
    end
    
    if params[:search]
      @corals = @search.results
    else
      @corals = Coral.all.paginate(:page=> params[:page], :per_page => pp)
    end
    
    @corals = PaperTrail::Version.find(params[:version]).reify if params[:version]

    # @corals = @corals.paginate(:page=> params[:page], :per_page => 20)

    respond_to do |format|
      format.html
      format.csv { send_data get_coral_csv(@corals) }
      
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
    
    # csv_string = get_main_csv(@observations, params[:contextual], params[:global])

    send_zip(@observations, 'traits.csv', params[:taxonomy], params[:contextual], params[:global])
      

    # send_data csv_string, 
    #  :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
    #  :disposition => "attachment; filename=ctdb_#{Date.today.strftime('%Y%m%d')}.csv"
          
  end

  # GET /corals/1
  # GET /corals/1.json
  def show
    @vfiles = Dir.glob("app/assets/images/veron/*")
    @hfiles = Dir.glob("app/assets/images/hughes/*")
    
    @coral = @item if @item
    @coral = Coral.find(params[:id]) if params[:id]
    

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
        if request.url.include? 'resources.csv'
          csv_string = get_resources_csv(@observations)
          filename = 'resources'
        else
          csv_string = get_main_csv(@observations, "", "", "")
          filename = 'observations'
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





  private
    # Use callbacks to share common setup or constraints between actions.
    def set_coral
      @coral = Coral.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def coral_params
      params.require(:coral).permit(:coral_name, :coral_description, :user_id, :approval_status, :major_clade, :family_molecules, :family_morphology, synonyms_attributes: [:id, :synonym_name, :synonym_notes, :_destroy])
    end

    

    
end
