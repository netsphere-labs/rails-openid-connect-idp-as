require "application_system_test_case"

class ScopesTest < ApplicationSystemTestCase
  setup do
    @scope = scopes(:one)
  end

  test "visiting the index" do
    visit scopes_url
    assert_selector "h1", text: "Scopes"
  end

  test "should create scope" do
    visit scopes_url
    click_on "New scope"

    click_on "Create Scope"

    assert_text "Scope was successfully created"
    click_on "Back"
  end

  test "should update Scope" do
    visit scope_url(@scope)
    click_on "Edit this scope", match: :first

    click_on "Update Scope"

    assert_text "Scope was successfully updated"
    click_on "Back"
  end

  test "should destroy Scope" do
    visit scope_url(@scope)
    click_on "Destroy this scope", match: :first

    assert_text "Scope was successfully destroyed"
  end
end
