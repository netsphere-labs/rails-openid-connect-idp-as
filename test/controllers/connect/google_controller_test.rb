require "test_helper"

class Connect::GooglesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @connect_google = connect_googles(:one)
  end

  test "should get index" do
    get connect_googles_url
    assert_response :success
  end

  test "should get new" do
    get new_connect_google_url
    assert_response :success
  end

  test "should create connect_google" do
    assert_difference('Connect::Google.count') do
      post connect_googles_url, params: { connect_google: {  } }
    end

    assert_redirected_to connect_google_url(Connect::Google.last)
  end

  test "should show connect_google" do
    get connect_google_url(@connect_google)
    assert_response :success
  end

  test "should get edit" do
    get edit_connect_google_url(@connect_google)
    assert_response :success
  end

  test "should update connect_google" do
    patch connect_google_url(@connect_google), params: { connect_google: {  } }
    assert_redirected_to connect_google_url(@connect_google)
  end

  test "should destroy connect_google" do
    assert_difference('Connect::Google.count', -1) do
      delete connect_google_url(@connect_google)
    end

    assert_redirected_to connect_googles_url
  end
end
