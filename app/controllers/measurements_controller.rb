class MeasurementsController < ApplicationController
  before_action :admin_user
  before_action :set_measurement, only: [:show, :edit, :update, :destroy]


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
