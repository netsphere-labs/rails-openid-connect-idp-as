require "application_system_test_case"

class FakeUsersTest < ApplicationSystemTestCase
  setup do
    @fake_user = fake_users(:one)
  end

  test "visiting the index" do
    visit fake_users_url
    assert_selector "h1", text: "Fake Users"
  end

  test "creating a Fake user" do
    visit fake_users_url
    click_on "New Fake User"

    click_on "Create Fake user"

    assert_text "Fake user was successfully created"
    click_on "Back"
  end

  test "updating a Fake user" do
    visit fake_users_url
    click_on "Edit", match: :first

    click_on "Update Fake user"

    assert_text "Fake user was successfully updated"
    click_on "Back"
  end

  test "destroying a Fake user" do
    visit fake_users_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Fake user was successfully destroyed"
  end
end
