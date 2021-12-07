require "test_helper"

class FakeUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fake_user = fake_users(:one)
  end

  test "should get index" do
    get fake_users_url
    assert_response :success
  end

  test "should get new" do
    get new_fake_user_url
    assert_response :success
  end

  test "should create fake_user" do
    assert_difference('FakeUser.count') do
      post fake_users_url, params: { fake_user: {  } }
    end

    assert_redirected_to fake_user_url(FakeUser.last)
  end

  test "should show fake_user" do
    get fake_user_url(@fake_user)
    assert_response :success
  end

  test "should get edit" do
    get edit_fake_user_url(@fake_user)
    assert_response :success
  end

  test "should update fake_user" do
    patch fake_user_url(@fake_user), params: { fake_user: {  } }
    assert_redirected_to fake_user_url(@fake_user)
  end

  test "should destroy fake_user" do
    assert_difference('FakeUser.count', -1) do
      delete fake_user_url(@fake_user)
    end

    assert_redirected_to fake_users_url
  end
end
