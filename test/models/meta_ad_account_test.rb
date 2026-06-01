require "test_helper"

class MetaAdAccountTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:acme)
    @meta_account = meta_ad_accounts(:acme_meta)
  end

  # ── Associations ─────────────────────────────────────────────
  test "belongs to account" do
    assert_equal @account, @meta_account.account
  end

  test "has many meta_ad_campaigns" do
    assert_respond_to @meta_account, :meta_ad_campaigns
  end

  # ── Validations ──────────────────────────────────────────────
  test "validates status inclusion" do
    @meta_account.status = "invalid"
    assert_not @meta_account.valid?
    assert_includes @meta_account.errors[:status], "is not included in the list"
  end

  test "valid statuses" do
    %w[connected disconnected error].each do |s|
      @meta_account.status = s
      assert @meta_account.valid?, "Expected status '#{s}' to be valid"
    end
  end

  # ── Scopes ───────────────────────────────────────────────────
  test "connected scope" do
    assert_includes MetaAdAccount.connected, @meta_account
  end

  # ── Instance Methods ─────────────────────────────────────────
  test "connected? returns true when status is connected" do
    assert @meta_account.connected?
  end

  test "connected? returns false when status is disconnected" do
    @meta_account.status = "disconnected"
    assert_not @meta_account.connected?
  end

  test "token_expired? returns false when no expiry" do
    @meta_account.token_expires_at = nil
    assert_not @meta_account.token_expired?
  end

  test "token_expired? returns true when expired" do
    @meta_account.token_expires_at = 1.hour.ago
    assert @meta_account.token_expired?
  end

  test "token_expired? returns false when not expired" do
    @meta_account.token_expires_at = 1.hour.from_now
    assert_not @meta_account.token_expired?
  end

  test "update_tokens! sets fields from auth hash" do
    auth = {
      "credentials" => {
        "token" => "new_token_123",
        "expires_at" => 1.hour.from_now.to_i
      },
      "info" => {
        "email" => "new@example.com"
      }
    }

    @meta_account.update_tokens!(auth)
    @meta_account.reload

    assert_equal "new@example.com", @meta_account.meta_email
    assert_equal "connected", @meta_account.status
    assert_not_nil @meta_account.token_expires_at
  end
end
