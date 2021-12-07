require "application_system_test_case"

class Connect::FacebooksTest < ApplicationSystemTestCase
  setup do
    @connect_facebook = connect_facebooks(:one)
  end

  test "visiting the index" do
    visit connect_facebooks_url
    assert_selector "h1", text: "Connect/Facebooks"
  end

  test "creating a Facebook" do
    visit connect_facebooks_url
    click_on "New Connect/Facebook"

    click_on "Create Facebook"

    assert_text "Facebook was successfully created"
    click_on "Back"
  end

  test "updating a Facebook" do
    visit connect_facebooks_url
    click_on "Edit", match: :first

    click_on "Update Facebook"

    assert_text "Facebook was successfully updated"
    click_on "Back"
  end

  test "destroying a Facebook" do
    visit connect_facebooks_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Facebook was successfully destroyed"
  end
end
