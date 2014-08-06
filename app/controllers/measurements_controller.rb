class MeasurementsController < ApplicationController
  before_action :signed_in_user
  before_action :set_measurement, only: [:show, :edit, :update, :destroy]
  


  # 
  # # GET /measurements
  # # GET /measurements.json
  # def index
  #   @measurements = Measurement.all
  # end
  # 
  # # GET /measurements/1
  # # GET /measurements/1.json
  # def show
  # end
  # 
  # # GET /measurements/new
  # def new
  #   @measurement = Measurement.new
  # end
  # 
  # # GET /measurements/1/edit
  # def edit
  # end
  # 
  # # POST /measurements
  # # POST /measurements.json
  # def create
  #   @measurement = Measurement.new(measurement_params)
  # 
  #   respond_to do |format|
  #     if @measurement.save
  #       format.html { redirect_to @measurement, notice: 'Measurement was successfully created.' }
  #       format.json { render action: 'show', status: :created, location: @measurement }
  #     else
  #       format.html { render action: 'new' }
  #       format.json { render json: @measurement.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end
  # 
  # # PATCH/PUT /measurements/1
  # # PATCH/PUT /measurements/1.json
  # def update
  #   respond_to do |format|
  #     if @measurement.update(measurement_params)
  #       format.html { redirect_to @measurement, notice: 'Measurement was successfully updated.' }
  #       format.json { render action: 'show', status: :ok, location: @measurement }
  #     else
  #       format.html { render action: 'edit' }
  #       format.json { render json: @measurement.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end
  # 
  # # DELETE /measurements/1
  # # DELETE /measurements/1.json
  # def destroy
  #   @measurement.destroy
  #   respond_to do |format|
  #     format.html { redirect_to measurements_url }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_measurement
      @measurement = Measurement.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def measurement_params
      params.require(:measurement).permit(:observation_id, :user_id, :trait_id, :standard_id, :value, :traitvalue_id, :value_type, :orig_value, :precision_type, :precision, :precision_upper, :replicates, :methodology_id)
    end
end
