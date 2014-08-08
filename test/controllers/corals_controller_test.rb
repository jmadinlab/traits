require 'test_helper'

class CoralsControllerTest < ActionController::TestCase
  setup do
    @coral = corals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:corals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create coral" do
    assert_difference('Coral.count') do
      post :create, coral: { coral_description: @coral.coral_description, coral_name: @coral.coral_name }
    end

    assert_redirected_to coral_path(assigns(:coral))
  end

  test "should show coral" do
    get :show, id: @coral
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @coral
    assert_response :success
  end

  test "should update coral" do
    patch :update, id: @coral, coral: { coral_description: @coral.coral_description, coral_name: @coral.coral_name }
    assert_redirected_to coral_path(assigns(:coral))
  end

  test "should destroy coral" do
    assert_difference('Coral.count', -1) do
      delete :destroy, id: @coral
    end

    assert_redirected_to corals_path
  end
end
