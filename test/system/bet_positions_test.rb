require "application_system_test_case"

class BetPositionsTest < ApplicationSystemTestCase
  setup do
    @bet_position = bet_positions(:one)
  end

  test "visiting the index" do
    visit bet_positions_url
    assert_selector "h1", text: "Bet positions"
  end

  test "should create bet position" do
    visit bet_positions_url
    click_on "New bet position"

    fill_in "Bet", with: @bet_position.bet_id
    fill_in "Driver", with: @bet_position.driver_id
    fill_in "Position", with: @bet_position.position
    click_on "Create Bet position"

    assert_text "Bet position was successfully created"
    click_on "Back"
  end

  test "should update Bet position" do
    visit bet_position_url(@bet_position)
    click_on "Edit this bet position", match: :first

    fill_in "Bet", with: @bet_position.bet_id
    fill_in "Driver", with: @bet_position.driver_id
    fill_in "Position", with: @bet_position.position
    click_on "Update Bet position"

    assert_text "Bet position was successfully updated"
    click_on "Back"
  end

  test "should destroy Bet position" do
    visit bet_position_url(@bet_position)
    accept_confirm { click_on "Destroy this bet position", match: :first }

    assert_text "Bet position was successfully destroyed"
  end
end
