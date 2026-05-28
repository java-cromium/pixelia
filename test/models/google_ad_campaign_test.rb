require "test_helper"

class GoogleAdCampaignTest < ActiveSupport::TestCase
  setup do
    @draft = google_ad_campaigns(:draft_campaign)
    @synced = google_ad_campaigns(:synced_campaign)
  end

  test "valid campaign" do
    assert @draft.valid?
  end

  test "requires name" do
    @draft.name = nil
    assert_not @draft.valid?
    assert_includes @draft.errors[:name], "can't be blank"
  end

  test "requires valid campaign_type" do
    @draft.campaign_type = "invalid"
    assert_not @draft.valid?
  end

  test "requires valid status" do
    @draft.status = "invalid"
    assert_not @draft.valid?
  end

  test "budget_amount_micros must be positive" do
    @draft.budget_amount_micros = -1
    assert_not @draft.valid?
  end

  test "budget_display formats correctly" do
    @draft.budget_amount_micros = 50_000_000
    assert_equal "$50.00/day", @draft.budget_display
  end

  test "budget_display returns nil when no budget" do
    @draft.budget_amount_micros = nil
    assert_nil @draft.budget_display
  end

  test "synced? returns true when google_campaign_id present" do
    assert @synced.synced?
  end

  test "synced? returns false for draft" do
    assert_not @draft.synced?
  end

  test "draft? returns true for draft campaigns" do
    assert @draft.draft?
  end

  test "draft? returns false for non-draft" do
    assert_not @synced.draft?
  end

  test "active scope returns enabled and paused" do
    active = GoogleAdCampaign.active
    assert_includes active, @synced
  end

  test "by_type scope filters by type" do
    search = GoogleAdCampaign.by_type("search")
    assert_includes search, @draft
    assert_not_includes search, @synced
  end
end
