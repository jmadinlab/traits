require 'test_helper'

class CitationsControllerTest < ActionController::TestCase
  setup do
    @citation = citations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:citations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create citation" do
    assert_difference('Citation.count') do
      post :create, citation: { resource_id: @citation.resource_id, trait_id: @citation.trait_id }
    end

    assert_redirected_to citation_path(assigns(:citation))
  end

  test "should show citation" do
    get :show, id: @citation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @citation
    assert_response :success
  end

  test "should update citation" do
    patch :update, id: @citation, citation: { resource_id: @citation.resource_id, trait_id: @citation.trait_id }
    assert_redirected_to citation_path(assigns(:citation))
  end

  test "should destroy citation" do
    assert_difference('Citation.count', -1) do
      delete :destroy, id: @citation
    end

    assert_redirected_to citations_path
  end
end
