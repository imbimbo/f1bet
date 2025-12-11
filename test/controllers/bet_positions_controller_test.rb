require "test_helper"

class BetPositionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bet_position = bet_positions(:one)
  end

  test "should get index" do
    get bet_positions_url
    assert_response :success
  end

  test "should get new" do
    get new_bet_position_url
    assert_response :success
  end

  test "should create bet_position" do
    assert_difference("BetPosition.count") do
      post bet_positions_url, params: { bet_position: { bet_id: @bet_position.bet_id, driver_id: @bet_position.driver_id, position: @bet_position.position } }
    end

    assert_redirected_to bet_position_url(BetPosition.last)
  end

  test "should show bet_position" do
    get bet_position_url(@bet_position)
    assert_response :success
  end

  test "should get edit" do
    get edit_bet_position_url(@bet_position)
    assert_response :success
  end

  test "should update bet_position" do
    patch bet_position_url(@bet_position), params: { bet_position: { bet_id: @bet_position.bet_id, driver_id: @bet_position.driver_id, position: @bet_position.position } }
    assert_redirected_to bet_position_url(@bet_position)
  end

  test "should destroy bet_position" do
    assert_difference("BetPosition.count", -1) do
      delete bet_position_url(@bet_position)
    end

    assert_redirected_to bet_positions_url
  end
end
