class SpeciesController < ApplicationController

  before_action :contributor, except: [:index, :show, :export]
  before_action :set_specie, only: [:show, :edit, :update, :destroy]
  before_action :admin_user, only: [:destroy, :new, :create, :edit, :update]

  # GET /species
  # GET /species.json
  def index
    # @species = Specie.search(params[:search])

    pp = 15
    pp = 9999 if params[:pp]
    
    @search = Specie.search do
      fulltext params[:search]
      paginate page: params[:page], per_page: pp
    end
    
    if params[:search]
      @species = @search.results
    else
      @species = Specie.all.paginate(:page=> params[:page], :per_page => pp)
    end
    
    @species = PaperTrail::Version.find(params[:version]).reify if params[:version]

    # @species = @species.paginate(:page=> params[:page], :per_page => 20)

    respond_to do |format|
      format.html
      format.csv { send_data get_specie_csv(@species) }
      
    end    
  end

  def export
    checked = params[:checked]


    if !signed_in? | (signed_in? && (!current_user.admin? | !current_user.contributor?))
      @observations = Observation.where(:private => false).where(:specie_id => params[:checked])        
    end
    
    if signed_in? && current_user.contributor?
      @observations = Observation.where(['observations.private IS false OR (observations.user_id = ? AND observations.private true)', current_user.id]).where(:specie_id => params[:checked])
    end

    if signed_in? && current_user.admin?
      @observations = Observation.where(:specie_id => params[:checked])        
    end
    
    # csv_string = get_main_csv(@observations, params[:contextual], params[:global])

    send_zip(@observations, 'traits.csv', params[:taxonomy], params[:contextual], params[:global])
      

    # send_data csv_string, 
    #  :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
    #  :disposition => "attachment; filename=ctdb_#{Date.today.strftime('%Y%m%d')}.csv"
          
  end

  # GET /species/1
  # GET /species/1.json
  def show
    @vfiles = Dir.glob("app/assets/images/veron/*")
    @hfiles = Dir.glob("app/assets/images/hughes/*")
    
    @specie = @item if @item
    @specie = Specie.find(params[:id]) if params[:id]
    

    if !signed_in? | (signed_in? && (!current_user.admin? | !current_user.contributor?))
      #@observations = Observation.where(['observations.specie_id IS ? AND observations.private IS ?', @specie.id, false])
      # just a better approach to find active `
      @observations = @specie.observations.where(private: false)
    end
    
    if signed_in? && current_user.contributor?
      #@observations = Observation.where(['observations.specie_id IS ? AND (observations.private IS ? OR (observations.user_id IS ? AND observations.private IS ?))', @specie.id, false, current_user.id, true])
      @observations = Observation.where(['observations.specie_id = ? AND (observations.private IS false OR (observations.user_id = ? AND observations.private IS true))', @specie.id,  current_user.id])
    end

    if signed_in? && current_user.admin?
      @observations = Observation.where(:specie_id => @specie.id)
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

  # GET /species/new
  def new
    @specie = Specie.new
  end

  # GET /species/1/edit
  def edit
  end

  # POST /species
  # POST /species.json
  def create
    @specie = Specie.new(specie_params)

    if @specie.save
      redirect_to @specie, flash: {success: "Species was successfully created." }
    else
      render action: 'new' 
    end
  end

  # PATCH/PUT /species/1
  # PATCH/PUT /species/1.json
  def update
    if @specie.update(specie_params)
      redirect_to @specie, flash: {success: "Species was successfully updated." }
    else
      render action: 'edit'
    end
  end

  # DELETE /species/1
  # DELETE /species/1.json
  def destroy
    @specie.destroy
    respond_to do |format|
      format.html { redirect_to species_url }
      format.json { head :no_content }
    end
  end





  private
    # Use callbacks to share common setup or constraints between actions.
    def set_specie
      @specie = Specie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def specie_params
      params.require(:specie).permit(:specie_name, :specie_description, :user_id, :approval_status, :major_clade, :family_molecules, :family_morphology, synonyms_attributes: [:id, :synonym_name, :synonym_notes, :_destroy])
    end

    

    
end
