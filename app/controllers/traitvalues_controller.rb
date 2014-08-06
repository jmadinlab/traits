class TraitvaluesController < ApplicationController
  before_action :signed_in_user
  before_action :set_measurement, only: [:show, :edit, :update, :destroy]
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_measurement
      @value = Traitvalue.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def measurement_params
      params.require(:traitvalue).permit(:value_name, :value_description)
    end
end
