class MetaAdAccount < ApplicationRecord
  belongs_to :account
  has_many :meta_ad_campaigns, dependent: :destroy

  STATUSES = %w[connected disconnected error].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :account_id, uniqueness: true

  encrypts :access_token

  scope :connected, -> { where(status: "connected") }

  def connected?
    status == "connected"
  end

  def token_expired?
    token_expires_at.present? && token_expires_at < Time.current
  end

  def update_tokens!(auth_hash)
    update!(
      access_token: auth_hash.dig("credentials", "token"),
      token_expires_at: auth_hash.dig("credentials", "expires_at") ? Time.at(auth_hash["credentials"]["expires_at"]) : nil,
      meta_email: auth_hash.dig("info", "email"),
      status: "connected"
    )
  end
end
