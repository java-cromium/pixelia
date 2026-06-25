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

  test "same CID cannot be linked twice to same account" do
    duplicate = GoogleAdAccount.new(
      account: @google_account.account,
      google_customer_id: @google_account.google_customer_id,
      google_email: "dup@acme.com",
      status: "connected"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:google_customer_id], "is already linked to this account"
  end

  test "allows multiple google ad accounts per account with different CIDs" do
    second = GoogleAdAccount.new(
      account: @google_account.account,
      google_customer_id: "9999999999",
      google_email: "second@acme.com",
      status: "connected"
    )
    assert second.valid?
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

  test "requires google_customer_id for cid connection_type" do
    ga = GoogleAdAccount.new(
      account: accounts(:globex),
      connection_type: "cid",
      status: "connected",
      google_customer_id: ""
    )
    assert_not ga.valid?
    assert_includes ga.errors[:google_customer_id], "can't be blank"
  end

  test "validates CID format" do
    ga = GoogleAdAccount.new(
      account: accounts(:globex),
      connection_type: "cid",
      status: "connected",
      google_customer_id: "123"
    )
    assert_not ga.valid?
    assert_includes ga.errors[:google_customer_id], "must be a valid 10-digit Customer ID"
  end

  test "accepts CID with dashes" do
    ga = GoogleAdAccount.new(
      account: accounts(:globex),
      connection_type: "cid",
      status: "connected",
      google_customer_id: "123-456-7890"
    )
    assert ga.valid?
  end

  test "normalizes CID by removing dashes on save" do
    ga = GoogleAdAccount.create!(
      account: accounts(:globex),
      connection_type: "cid",
      status: "connected",
      google_customer_id: "123-456-7890"
    )
    assert_equal "1234567890", ga.google_customer_id
  end

  test "display_name returns nickname when present" do
    @google_account.nickname = "Main Account"
    assert_equal "Main Account", @google_account.display_name
  end

  test "display_name falls back to email then CID" do
    @google_account.nickname = nil
    assert_equal "ads@acme.com", @google_account.display_name

    @google_account.google_email = nil
    assert_equal "123-456-7890", @google_account.display_name
  end

  test "formatted_customer_id formats as XXX-XXX-XXXX" do
    @google_account.google_customer_id = "1234567890"
    assert_equal "123-456-7890", @google_account.formatted_customer_id
  end

  test "connection_type must be valid" do
    @google_account.connection_type = "invalid"
    assert_not @google_account.valid?
  end

  test "oauth? and cid? helpers" do
    @google_account.connection_type = "oauth"
    assert @google_account.oauth?
    assert_not @google_account.cid?

    @google_account.connection_type = "cid"
    assert @google_account.cid?
    assert_not @google_account.oauth?
  end
end
