require 'test_helper'

class MeasurementsControllerTest < ActionController::TestCase
  setup do
    @measurement = measurements(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:measurements)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create measurement" do
    assert_difference('Measurement.count') do
      post :create, measurement: { observation_id: @measurement.observation_id, orig_value: @measurement.orig_value, precision: @measurement.precision, precision_type: @measurement.precision_type, precision_upper: @measurement.precision_upper, replicates: @measurement.replicates, standard_id: @measurement.standard_id, trait_id: @measurement.trait_id, user_id: @measurement.user_id, value: @measurement.value }
    end

    assert_redirected_to measurement_path(assigns(:measurement))
  end

  test "should show measurement" do
    get :show, id: @measurement
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @measurement
    assert_response :success
  end

  test "should update measurement" do
    patch :update, id: @measurement, measurement: { observation_id: @measurement.observation_id, orig_value: @measurement.orig_value, precision: @measurement.precision, precision_type: @measurement.precision_type, precision_upper: @measurement.precision_upper, replicates: @measurement.replicates, standard_id: @measurement.standard_id, trait_id: @measurement.trait_id, user_id: @measurement.user_id, value: @measurement.value }
    assert_redirected_to measurement_path(assigns(:measurement))
  end

  test "should destroy measurement" do
    assert_difference('Measurement.count', -1) do
      delete :destroy, id: @measurement
    end

    assert_redirected_to measurements_path
  end
end
