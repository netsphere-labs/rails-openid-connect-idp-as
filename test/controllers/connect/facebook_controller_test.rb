require "test_helper"

class Connect::FacebooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @connect_facebook = connect_facebooks(:one)
  end

  test "should get index" do
    get connect_facebooks_url
    assert_response :success
  end

  test "should get new" do
    get new_connect_facebook_url
    assert_response :success
  end

  test "should create connect_facebook" do
    assert_difference('Connect::Facebook.count') do
      post connect_facebooks_url, params: { connect_facebook: {  } }
    end

    assert_redirected_to connect_facebook_url(Connect::Facebook.last)
  end

  test "should show connect_facebook" do
    get connect_facebook_url(@connect_facebook)
    assert_response :success
  end

  test "should get edit" do
    get edit_connect_facebook_url(@connect_facebook)
    assert_response :success
  end

  test "should update connect_facebook" do
    patch connect_facebook_url(@connect_facebook), params: { connect_facebook: {  } }
    assert_redirected_to connect_facebook_url(@connect_facebook)
  end

  test "should destroy connect_facebook" do
    assert_difference('Connect::Facebook.count', -1) do
      delete connect_facebook_url(@connect_facebook)
    end

    assert_redirected_to connect_facebooks_url
  end
end
