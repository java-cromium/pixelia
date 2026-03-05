require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "admin can access dashboard" do
    sign_in users(:admin)
    get admin_root_url
    assert_response :success
  end

  test "client_user cannot access admin dashboard" do
    sign_in users(:client_user_one)
    get admin_root_url
    assert_redirected_to root_url
  end

  test "unauthenticated user is redirected to login" do
    get admin_root_url
    assert_redirected_to new_user_session_url
  end
end
