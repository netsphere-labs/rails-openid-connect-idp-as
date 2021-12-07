require "application_system_test_case"

class Connect::GooglesTest < ApplicationSystemTestCase
  setup do
    @connect_google = connect_googles(:one)
  end

  test "visiting the index" do
    visit connect_googles_url
    assert_selector "h1", text: "Connect/Googles"
  end

  test "creating a Google" do
    visit connect_googles_url
    click_on "New Connect/Google"

    click_on "Create Google"

    assert_text "Google was successfully created"
    click_on "Back"
  end

  test "updating a Google" do
    visit connect_googles_url
    click_on "Edit", match: :first

    click_on "Update Google"

    assert_text "Google was successfully updated"
    click_on "Back"
  end

  test "destroying a Google" do
    visit connect_googles_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Google was successfully destroyed"
  end
end
