class ReleasesController < ApplicationController
  before_action :admin_user, except: [:index, :show]
  before_action :set_release, only: [:edit, :update, :destroy]

  # GET /releases
  # GET /releases.json
  def index
    @releases = Release.all

    if params[:all]
      @releases = @releases.paginate(page: params[:page], per_page: 9999)
    else
      @releases = @releases.paginate(page: params[:page])
    end

    @snapzips = Dir.glob("#{Rails.root}/public/releases/*.zip")
    @snapzips = @snapzips.collect { |x| File.basename(x, ".zip") }

    respond_to do |format|
      format.html
      format.csv { send_data Release.all.to_csv }
    end    

  end

  # GET /releases/1
  # GET /releases/1.json
  def show

      puts "HERE ========================================="
      puts params[:id]
      puts request.url

    if params[:id].include? "ctdb_"
      respond_to do |format|

        format.csv {
          if request.url.include? 'resources.csv'
            send_file("#{Rails.root}/public/releases/#{params[:id]}/resources_#{params[:id][5..13]}.csv", type: "application/txt") 
          else

            send_file("#{Rails.root}/public/releases/#{params[:id]}/data_#{params[:id][5..13]}.csv", type: "application/txt") 
          end
        }
      end
    
    else
      puts "QWERYTGHJBHJB<BHJ"
      @release = Release.find(params[:id])
      send_file("#{Rails.root}/public/releases/ctdb_#{@release.release_code}.zip", type: "application/zip")    


    end

  end


  # GET /releases/new
  def new
    @release = Release.new
  end

  # GET /releases/1/edit
  def edit
  end

  # POST /releases
  # POST /releases.json
  def create
    @release = Release.new(release_params)

    respond_to do |format|
      if @release.save
        format.html { redirect_to releases_path, flash: {success: "Release was successfully created." } }
        format.json { render :show, status: :created, location: @release }
      else
        format.html { render :new }
        format.json { render json: @release.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /releases/1
  # PATCH/PUT /releases/1.json
  def update
    respond_to do |format|
      if @release.update(release_params)
        format.html { redirect_to releases_path, flash: {success: "Release was successfully updated." } }
        format.json { render :show, status: :ok, location: @release }
      else
        format.html { render :edit }
        format.json { render json: @release.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /releases/1
  # DELETE /releases/1.json
  def destroy
    @release.destroy
    respond_to do |format|
      format.html { redirect_to releases_url, flash: {success: "Release was successfully deleted." } }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_release
      @release = Release.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def release_params
      params.require(:release).permit(:user_id, :release_code, :release_date, :release_notes, :release_link)
    end
end
