require "test_helper"

class ScopesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @scope = scopes(:one)
  end

  test "should get index" do
    get scopes_url
    assert_response :success
  end

  test "should get new" do
    get new_scope_url
    assert_response :success
  end

  test "should create scope" do
    assert_difference("Scope.count") do
      post scopes_url, params: { scope: {} }
    end

    assert_redirected_to scope_url(Scope.last)
  end

  test "should show scope" do
    get scope_url(@scope)
    assert_response :success
  end

  test "should get edit" do
    get edit_scope_url(@scope)
    assert_response :success
  end

  test "should update scope" do
    patch scope_url(@scope), params: { scope: {} }
    assert_redirected_to scope_url(@scope)
  end

  test "should destroy scope" do
    assert_difference("Scope.count", -1) do
      delete scope_url(@scope)
    end

    assert_redirected_to scopes_url
  end
end
