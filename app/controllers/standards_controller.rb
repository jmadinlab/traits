class StandardsController < ApplicationController
  # before_action :signed_in_user
  before_action :contributor, except: [:index, :show, :export]
  before_action :set_standard, only: [:show, :edit, :update, :destroy]
  before_action :admin_user, only: :destroy

  # GET /standards
  # GET /standards.json
  def index

    @search = Standard.search do
      fulltext params[:search]
      order_by :standard_class_sortable, :asc

      if params[:all]
        paginate page: params[:page], per_page: 9999
      else
        paginate page: params[:page]
      end
    end
    @standards = @search.results

    respond_to do |format|
      format.html
      format.csv { send_data Standard.all.to_csv }      
    end    

  end

  # GET /standards/1
  # GET /standards/1.json
  def show
    @observations = Observation.joins(:measurements).where('measurements.standard_id = ?', @standard.id)
    @observations = observation_filter(@observations)

    respond_to do |format|
      format.html { @observations = @observations.paginate(page: params[:page]) }
      format.csv { download_observations(@observations, params[:taxonomy], params[:contextual] || "on", params[:global]) }
      format.zip{ send_zip(@observations, params[:taxonomy], params[:contextual] || "on", params[:global]) }
    end

  end

  def export
    @observations = Observation.joins(:measurements).where(:measurements => {:standard_id => params[:checked]})
    @observations = observation_filter(@observations)

    send_zip(@observations, 'data.csv', params[:taxonomy], params[:contextual], params[:global])          
  end


  # GET /standards/new
  def new
    @standard = Standard.new
  end

  # GET /standards/1/edit
  def edit
  end

  # POST /standards
  # POST /standards.json
  def create
    @standard = Standard.new(standard_params)

    if @standard.save
      redirect_to @standard, flash: {success: "Standard was successfully created." }
    else
      render action: 'new' 
    end
  end

  # PATCH/PUT /standards/1
  # PATCH/PUT /standards/1.json
  def update
    if @standard.update(standard_params)
      redirect_to @standard, flash: {success: "Standard was successfully updated." }
    else
      render action: 'edit'
    end
  end

  # DELETE /standards/1
  # DELETE /standards/1.json
  def destroy
    @standard.destroy
    respond_to do |format|
      format.html { redirect_to standards_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_standard
      @standard = Standard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def standard_params
      params.require(:standard).permit(:standard_name, :standard_unit, :standard_class, :standard_description, :user_id, :approval_status)
    end
end
