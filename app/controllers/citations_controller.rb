class CitationsController < ApplicationController
  before_action :signed_in_user
  before_action :contributor
  before_action :set_citation, only: [:show, :edit, :update, :destroy]
  before_action :admin_user, only: :destroy

  # GET /citations
  # GET /citations.json
  def index
    @citations = Citation.all
    
    respond_to do |format|
      format.html
      format.csv { send_data @citations.to_csv }
    end    
    
  end

  # GET /citations/1
  # GET /citations/1.json
  def show
  end

  # GET /citations/new
  def new
    @citation = Citation.new
  end

  # GET /citations/1/edit
  def edit
  end

  # POST /citations
  # POST /citations.json
  def create
    @citation = Citation.new(citation_params)

    if @citation.save
      redirect_to citations_path, flash: {success: "Citation was successfully created." }
    else
      render action: 'new' 
    end
  end

  # PATCH/PUT /citations/1
  # PATCH/PUT /citations/1.json
  def update
    if @citation.update(citation_params)
      redirect_to citations_path, flash: {success: "Citation was successfully updated." }
    else
      render action: 'edit'
    end
  end

  # DELETE /citations/1
  # DELETE /citations/1.json
  def destroy
    @citation.destroy
    respond_to do |format|
      format.html { redirect_to citations_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_citation
      @citation = Citation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def citation_params
      params.require(:citation).permit(:trait_id, :resource_id, :user_id)
    end
end
