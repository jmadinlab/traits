class SpeciesController < ApplicationController

  before_action :contributor, except: [:index, :show, :export]
  before_action :set_specie, only: [:show, :edit, :update, :destroy]
  before_action :admin_user, only: [:destroy, :new, :create, :edit, :update]

  # GET /species
  # GET /species.json
  def index

    @search = Specie.search do
      fulltext params[:search]
      order_by :specie_name_sortable, :asc
      
      if params[:all]
        paginate page: params[:page], per_page: 9999
      else
        paginate page: params[:page]
      end
    end
    @species = @search.results

    respond_to do |format|
      format.html
      format.csv { send_data get_specie_csv }
    end    
  end

  def export
    if params[:checked]
      @observations = Observation.where(:specie_id => params[:checked])
      @observations = observation_filter(@observations)
    else
      @observations = []
    end

    send_zip(@observations, params[:taxonomy], params[:contextual], params[:global])          
  end

  # GET /species/1
  # GET /species/1.json
  def show
    @vfiles = Dir.glob("public/images/veron/*")
    @hfiles = Dir.glob("app/assets/images/hughes/*")
    @cgfiles = Dir.glob("app/assets/images/veron_cg/*")

    @observations = Observation.where(:specie_id => @specie.id)
    @observations = observation_filter(@observations)

    respond_to do |format|
      format.html
      format.csv { download_observations(@observations, params[:taxonomy], params[:contextual] || "on", params[:global]) }
      format.zip{ send_zip(@observations, params[:taxonomy], params[:contextual] || "on", params[:global]) }
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

    def get_specie_csv
      csv_string = CSV.generate do |csv|
          csv << ["species_id", "master_species", "major_clade", "family_molecules", "family_morphology", "synonym_species", "specie_notes"]
          Specie.all.each do |specie|
            syn_vec = []
            specie.synonyms.each do |syn|
              syn_vec << syn.synonym_name
            end
            csv << [specie.id, specie.specie_name, specie.major_clade, specie.family_molecules, specie.family_morphology, syn_vec.join(", "), specie.specie_description]
          end
        end
     return csv_string
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_specie
      @specie = Specie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def specie_params
      params.require(:specie).permit(:specie_name, :specie_description, :user_id, :approval_status, :major_clade, :family_molecules, :family_morphology, synonyms_attributes: [:id, :synonym_name, :synonym_notes, :_destroy])
    end

    

    
end
