class SnapshotsController < ApplicationController
  before_action :admin_user, except: [:index, :show]
  before_action :set_snapshot, only: [:edit, :update, :destroy]

  # GET /snapshots
  # GET /snapshots.json
  def index
    @snapshots = Snapshot.all

    if params[:all]
      @snapshots = @snapshots.paginate(page: params[:page], per_page: 9999)
    else
      @snapshots = @snapshots.paginate(page: params[:page])
    end

    @snapzips = Dir.glob("#{Rails.root}/public/snapshots/*.zip")
    @snapzips = @snapzips.collect { |x| File.basename(x, ".zip") }

    respond_to do |format|
      format.html
      format.csv { send_data Snapshot.all.to_csv }
    end    

  end

  # GET /snapshots/1
  # GET /snapshots/1.json
  def show

      puts "HERE ========================================="
      puts params[:id]
      puts request.url

    if params[:id].include? "ctdb_"
      respond_to do |format|

        format.csv {
          if request.url.include? 'resources.csv'
            send_file("#{Rails.root}/public/snapshots/#{params[:id]}/resources_#{params[:id][5..13]}.csv", type: "application/txt") 
          else

            send_file("#{Rails.root}/public/snapshots/#{params[:id]}/data_#{params[:id][5..13]}.csv", type: "application/txt") 
          end
        }
      end
    
    else
      puts "QWERYTGHJBHJB<BHJ"
      @snapshot = Snapshot.find(params[:id])
      send_file("#{Rails.root}/public/snapshots/ctdb_#{@snapshot.snapshot_date.strftime('%Y%m%d')}.zip", type: "application/zip")    


    end

  end


  # GET /snapshots/new
  def new
    @snapshot = Snapshot.new
  end

  # GET /snapshots/1/edit
  def edit
  end

  # POST /snapshots
  # POST /snapshots.json
  def create
    @snapshot = Snapshot.new(snapshot_params)

    respond_to do |format|
      if @snapshot.save
        format.html { redirect_to snapshots_path, flash: {success: "Snapshot was successfully created." } }
        format.json { render :show, status: :created, location: @snapshot }
      else
        format.html { render :new }
        format.json { render json: @snapshot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /snapshots/1
  # PATCH/PUT /snapshots/1.json
  def update
    respond_to do |format|
      if @snapshot.update(snapshot_params)
        format.html { redirect_to snapshots_path, flash: {success: "Snapshot was successfully updated." } }
        format.json { render :show, status: :ok, location: @snapshot }
      else
        format.html { render :edit }
        format.json { render json: @snapshot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /snapshots/1
  # DELETE /snapshots/1.json
  def destroy
    @snapshot.destroy
    respond_to do |format|
      format.html { redirect_to snapshots_url, flash: {success: "Snapshot was successfully deleted." } }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_snapshot
      @snapshot = Snapshot.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def snapshot_params
      params.require(:snapshot).permit(:user_id, :snapshot_code, :snapshot_date, :snapshot_notes)
    end
end
