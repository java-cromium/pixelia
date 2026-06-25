class GoogleAdAccount < ApplicationRecord
  belongs_to :account
  has_many :google_ad_campaigns, dependent: :destroy

  STATUSES = %w[connected disconnected error].freeze
  CONNECTION_TYPES = %w[oauth cid].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :connection_type, inclusion: { in: CONNECTION_TYPES }
  validates :google_customer_id, uniqueness: { scope: :account_id, message: "is already linked to this account" }, allow_blank: true
  validates :google_customer_id, presence: true, if: -> { connection_type == "cid" }
  validates :google_customer_id, format: { with: /\A\d{3}-?\d{3}-?\d{4}\z/, message: "must be a valid 10-digit Customer ID" }, allow_blank: true

  encrypts :access_token
  encrypts :refresh_token

  scope :connected, -> { where(status: "connected") }
  scope :by_oauth, -> { where(connection_type: "oauth") }
  scope :by_cid, -> { where(connection_type: "cid") }

  before_save :normalize_customer_id

  def connected?
    status == "connected"
  end

  def oauth?
    connection_type == "oauth"
  end

  def cid?
    connection_type == "cid"
  end

  def token_expired?
    token_expires_at.present? && token_expires_at < Time.current
  end

  def display_name
    nickname.presence || google_email.presence || formatted_customer_id || "Google Ads Account ##{id}"
  end

  def formatted_customer_id
    return nil unless google_customer_id.present?
    cid = google_customer_id.gsub("-", "")
    "#{cid[0..2]}-#{cid[3..5]}-#{cid[6..9]}"
  end

  def update_tokens!(auth_hash)
    update!(
      access_token: auth_hash.dig("credentials", "token"),
      refresh_token: auth_hash.dig("credentials", "refresh_token") || refresh_token,
      token_expires_at: auth_hash.dig("credentials", "expires_at") ? Time.at(auth_hash["credentials"]["expires_at"]) : nil,
      google_email: auth_hash.dig("info", "email"),
      status: "connected"
    )
  end

  private

  def normalize_customer_id
    self.google_customer_id = google_customer_id.gsub("-", "") if google_customer_id.present?
  end
end
