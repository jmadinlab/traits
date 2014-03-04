class StandardsController < ApplicationController
  before_action :signed_in_user
  before_action :contributor
  before_action :set_standard, only: [:show, :edit, :update, :destroy]
  before_action :admin_user, only: :destroy

  # GET /standards
  # GET /standards.json
  def index
    @standards = Standard.search(params[:search])
    
    respond_to do |format|
      format.html
      format.csv { send_data @standards.to_csv }
    end    

  end

  # GET /standards/1
  # GET /standards/1.json
  def show
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
      params.require(:standard).permit(:standard_name, :standard_unit, :standard_class, :standard_description, :user_id)
    end
end
