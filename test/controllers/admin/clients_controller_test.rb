require "test_helper"

class Admin::ClientsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @client_user = users(:client_user_one)
    @client = clients(:acme)
  end

  # ── Authenticated super_admin ─────────────────────────────────
  test "admin can list clients" do
    sign_in @admin
    get admin_clients_url
    assert_response :success
  end

  test "admin can view client" do
    sign_in @admin
    get admin_client_url(@client)
    assert_response :success
  end

  test "admin can access new client form" do
    sign_in @admin
    get new_admin_client_url
    assert_response :success
  end

  test "admin can create client" do
    sign_in @admin
    assert_difference("Client.count", 1) do
      post admin_clients_url, params: {
        client: { name: "NewCo", industry: "Finance", status: "active" }
      }
    end
    assert_redirected_to admin_client_url(Client.last)
  end

  test "admin can update client" do
    sign_in @admin
    patch admin_client_url(@client), params: {
      client: { name: "Acme Updated" }
    }
    assert_redirected_to admin_client_url(@client)
    assert_equal "Acme Updated", @client.reload.name
  end

  test "admin can destroy client" do
    sign_in @admin
    assert_difference("Client.count", -1) do
      delete admin_client_url(@client)
    end
    assert_redirected_to admin_clients_url
  end

  # ── Unauthenticated ───────────────────────────────────────────
  test "unauthenticated user is redirected from admin" do
    get admin_clients_url
    assert_redirected_to new_user_session_url
  end

  # ── Non-admin user ────────────────────────────────────────────
  test "client_user is redirected from admin" do
    sign_in @client_user
    get admin_clients_url
    assert_redirected_to root_url
  end
end
