require "test_helper"

class GoogleAdAccountTest < ActiveSupport::TestCase
  setup do
    @google_account = google_ad_accounts(:acme_google)
  end

  test "valid google ad account" do
    assert @google_account.valid?
  end

  test "requires valid status" do
    @google_account.status = "invalid"
    assert_not @google_account.valid?
  end

  test "account_id must be unique" do
    duplicate = GoogleAdAccount.new(
      account: @google_account.account,
      google_customer_id: "9999999999",
      google_email: "dup@acme.com",
      status: "connected"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:account_id], "has already been taken"
  end

  test "connected? returns true when status is connected" do
    assert @google_account.connected?
  end

  test "connected? returns false when disconnected" do
    @google_account.status = "disconnected"
    assert_not @google_account.connected?
  end

  test "token_expired? returns false when token is fresh" do
    @google_account.token_expires_at = 1.hour.from_now
    assert_not @google_account.token_expired?
  end

  test "token_expired? returns true when token is past" do
    @google_account.token_expires_at = 1.hour.ago
    assert @google_account.token_expired?
  end

  test "update_tokens! updates from auth hash" do
    # Create a fresh record via the model so encryption works
    account = accounts(:globex)
    ga = GoogleAdAccount.create!(
      account: account,
      google_customer_id: "5555555555",
      google_email: "old@globex.com",
      access_token: "old_token",
      refresh_token: "old_refresh",
      status: "connected"
    )

    auth = {
      "credentials" => {
        "token" => "new_access_token",
        "refresh_token" => "new_refresh_token",
        "expires_at" => 1.hour.from_now.to_i
      },
      "info" => {
        "email" => "new@globex.com"
      }
    }

    ga.update_tokens!(auth)
    ga.reload

    assert_equal "new@globex.com", ga.google_email
    assert_equal "connected", ga.status
  end

  test "connected scope returns only connected accounts" do
    connected = GoogleAdAccount.connected
    assert_includes connected, @google_account
  end
end
