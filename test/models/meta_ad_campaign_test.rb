require "test_helper"

class MetaAdCampaignTest < ActiveSupport::TestCase
  setup do
    @campaign = meta_ad_campaigns(:traffic_campaign)
    @active_campaign = meta_ad_campaigns(:active_campaign)
  end

  # ── Associations ─────────────────────────────────────────────
  test "belongs to account" do
    assert_equal accounts(:acme), @campaign.account
  end

  test "belongs to meta_ad_account" do
    assert_equal meta_ad_accounts(:acme_meta), @campaign.meta_ad_account
  end

  # ── Validations ──────────────────────────────────────────────
  test "requires name" do
    @campaign.name = nil
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:name], "can't be blank"
  end

  test "validates objective inclusion" do
    @campaign.objective = "INVALID"
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:objective], "is not included in the list"
  end

  test "validates status inclusion" do
    @campaign.status = "invalid"
    assert_not @campaign.valid?
    assert_includes @campaign.errors[:status], "is not included in the list"
  end

  test "validates daily_budget_cents numericality" do
    @campaign.daily_budget_cents = -100
    assert_not @campaign.valid?
  end

  test "allows nil daily_budget_cents" do
    @campaign.daily_budget_cents = nil
    assert @campaign.valid?
  end

  # ── Display Helpers ──────────────────────────────────────────
  test "daily_budget_display formats correctly" do
    @campaign.daily_budget_cents = 2000
    assert_equal "$20.00/day", @campaign.daily_budget_display
  end

  test "daily_budget_display returns nil when no budget" do
    @campaign.daily_budget_cents = nil
    assert_nil @campaign.daily_budget_display
  end

  test "lifetime_budget_display formats correctly" do
    @campaign.lifetime_budget_cents = 50000
    assert_equal "$500.00", @campaign.lifetime_budget_display
  end

  test "budget_display prefers daily over lifetime" do
    @campaign.daily_budget_cents = 2000
    @campaign.lifetime_budget_cents = 50000
    assert_equal "$20.00/day", @campaign.budget_display
  end

  test "objective_display strips prefix and titleizes" do
    assert_equal "Traffic", @campaign.objective_display
    @campaign.objective = "OUTCOME_AWARENESS"
    assert_equal "Awareness", @campaign.objective_display
  end

  # ── State Methods ────────────────────────────────────────────
  test "synced? returns true when meta_campaign_id present" do
    assert @active_campaign.synced?
  end

  test "synced? returns false when meta_campaign_id blank" do
    assert_not @campaign.synced?
  end

  test "draft? returns true for draft status" do
    assert @campaign.draft?
  end

  test "draft? returns false for active status" do
    assert_not @active_campaign.draft?
  end

  # ── Scopes ───────────────────────────────────────────────────
  test "active_campaigns scope" do
    results = MetaAdCampaign.active_campaigns
    assert_includes results, @active_campaign
    assert_not_includes results, @campaign  # draft
  end

  test "by_objective scope" do
    results = MetaAdCampaign.by_objective("OUTCOME_TRAFFIC")
    assert_includes results, @campaign
    assert_not_includes results, @active_campaign
  end
end
