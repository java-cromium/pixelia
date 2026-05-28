class GoogleAdCampaign < ApplicationRecord
  belongs_to :account
  belongs_to :google_ad_account

  CAMPAIGN_TYPES = %w[search display shopping performance_max].freeze
  STATUSES = %w[draft enabled paused removed].freeze

  validates :name, presence: true
  validates :campaign_type, inclusion: { in: CAMPAIGN_TYPES }
  validates :status, inclusion: { in: STATUSES }
  validates :budget_amount_micros, numericality: { greater_than: 0 }, allow_nil: true

  scope :active, -> { where(status: %w[enabled paused]) }
  scope :by_type, ->(type) { where(campaign_type: type) }

  def budget_display
    return nil unless budget_amount_micros
    "$#{'%.2f' % (budget_amount_micros / 1_000_000.0)}/day"
  end

  def synced?
    google_campaign_id.present?
  end

  def draft?
    status == "draft"
  end
end
