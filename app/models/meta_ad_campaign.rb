class MetaAdCampaign < ApplicationRecord
  belongs_to :account
  belongs_to :meta_ad_account

  OBJECTIVES = %w[
    OUTCOME_AWARENESS
    OUTCOME_ENGAGEMENT
    OUTCOME_LEADS
    OUTCOME_SALES
    OUTCOME_TRAFFIC
    OUTCOME_APP_PROMOTION
  ].freeze

  STATUSES = %w[draft active paused archived deleted].freeze

  validates :name, presence: true
  validates :objective, inclusion: { in: OBJECTIVES }
  validates :status, inclusion: { in: STATUSES }
  validates :daily_budget_cents, numericality: { greater_than: 0 }, allow_nil: true
  validates :lifetime_budget_cents, numericality: { greater_than: 0 }, allow_nil: true

  scope :active_campaigns, -> { where(status: %w[active paused]) }
  scope :by_objective, ->(obj) { where(objective: obj) }

  def daily_budget_display
    return nil unless daily_budget_cents
    "$#{'%.2f' % (daily_budget_cents / 100.0)}/day"
  end

  def lifetime_budget_display
    return nil unless lifetime_budget_cents
    "$#{'%.2f' % (lifetime_budget_cents / 100.0)}"
  end

  def budget_display
    daily_budget_display || lifetime_budget_display
  end

  def synced?
    meta_campaign_id.present?
  end

  def draft?
    status == "draft"
  end

  def objective_display
    objective.sub("OUTCOME_", "").titleize
  end
end
