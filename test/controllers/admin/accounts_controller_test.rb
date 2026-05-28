require "test_helper"

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @owner = users(:owner_one)
    @account = accounts(:acme)
  end

  # ── Authenticated super_admin ─────────────────────────────────
  test "admin can list accounts" do
    sign_in @admin
    get admin_accounts_url
    assert_response :success
  end

  test "admin can view account" do
    sign_in @admin
    get admin_account_url(@account)
    assert_response :success
  end

  test "admin can access new account form" do
    sign_in @admin
    get new_admin_account_url
    assert_response :success
  end

  test "admin can create account" do
    sign_in @admin
    assert_difference("Account.count", 1) do
      post admin_accounts_url, params: {
        account: { name: "NewCo", industry: "Finance", status: "active" }
      }
    end
    assert_redirected_to admin_account_url(Account.last)
  end

  test "admin can update account" do
    sign_in @admin
    patch admin_account_url(@account), params: {
      account: { name: "Acme Updated" }
    }
    assert_redirected_to admin_account_url(@account)
    assert_equal "Acme Updated", @account.reload.name
  end

  test "admin can destroy account" do
    sign_in @admin
    assert_difference("Account.count", -1) do
      delete admin_account_url(@account)
    end
    assert_redirected_to admin_accounts_url
  end

  # ── Unauthenticated ───────────────────────────────────────────
  test "unauthenticated user is redirected from admin" do
    get admin_accounts_url
    assert_redirected_to new_user_session_url
  end

  # ── Non-admin user ────────────────────────────────────────────
  test "owner is redirected from admin" do
    sign_in @owner
    get admin_accounts_url
    assert_redirected_to root_url
  end
end
