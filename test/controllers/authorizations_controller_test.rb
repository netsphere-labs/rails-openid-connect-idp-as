require "test_helper"

class AuthorizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @authorization = authorizations(:one)
  end

  test "should get index" do
    get authorizations_url
    assert_response :success
  end

  test "should get new" do
    get new_authorization_url
    assert_response :success
  end

  test "should create authorization" do
    assert_difference('Authorization.count') do
      post authorizations_url, params: { authorization: {  } }
    end

    assert_redirected_to authorization_url(Authorization.last)
  end

  test "should show authorization" do
    get authorization_url(@authorization)
    assert_response :success
  end

  test "should get edit" do
    get edit_authorization_url(@authorization)
    assert_response :success
  end

  test "should update authorization" do
    patch authorization_url(@authorization), params: { authorization: {  } }
    assert_redirected_to authorization_url(@authorization)
  end

  test "should destroy authorization" do
    assert_difference('Authorization.count', -1) do
      delete authorization_url(@authorization)
    end

    assert_redirected_to authorizations_url
  end
end
