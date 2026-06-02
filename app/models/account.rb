class Account < ApplicationRecord
  pay_customer stripe_attributes: :stripe_attributes

  encrypts :ai_api_key

  has_many :users, dependent: :destroy
  has_many :sites, dependent: :destroy
  has_many :ecommerce_stores, dependent: :destroy
  has_one  :google_ad_account, dependent: :destroy
  has_many :google_ad_campaigns, dependent: :destroy
  has_one  :meta_ad_account, dependent: :destroy
  has_many :meta_ad_campaigns, dependent: :destroy
  has_many :chat_conversations, dependent: :destroy

  AI_PROVIDERS = %w[openai gemini claude].freeze
  PLANS = %w[free starter growth].freeze
  SUBSCRIPTION_STATUSES = %w[trialing active past_due canceled].freeze

  PLAN_PRICES = {
    "starter" => ENV.fetch("STRIPE_STARTER_PRICE_ID", "price_starter_monthly"),
    "growth"  => ENV.fetch("STRIPE_GROWTH_PRICE_ID", "price_growth_monthly")
  }.freeze

  validates :name, presence: true
  validates :plan, inclusion: { in: PLANS }
  validates :subscription_status, inclusion: { in: SUBSCRIPTION_STATUSES }
  validates :stripe_customer_id, uniqueness: true, allow_blank: true
  validates :ai_provider, inclusion: { in: AI_PROVIDERS }, allow_blank: true

  scope :active, -> { where(subscription_status: "active") }
  scope :trialing, -> { where(subscription_status: "trialing") }

  def active_subscription?
    subscription_status.in?(%w[active trialing])
  end

  def trial_expired?
    subscription_status == "trialing" && trial_ends_at.present? && trial_ends_at < Time.current
  end

  def on_free_plan?
    plan == "free"
  end

  def ai_configured?
    ai_provider.present? && ai_api_key.present?
  end

  def stripe_attributes(pay_customer)
    { metadata: { account_id: id, account_name: name } }
  end
end
