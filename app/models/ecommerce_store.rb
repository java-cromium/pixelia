class EcommerceStore < ApplicationRecord
  belongs_to :project

  acts_as_tenant(:client)

  encrypts :api_key, :api_secret

  PLATFORMS = %w[shopify woocommerce].freeze

  validates :platform, presence: true, inclusion: { in: PLATFORMS }
  validates :store_url, presence: true

  def connected?
    api_key.present? && api_secret.present?
  end

  def masked_api_key
    return "Not set" if api_key.blank?
    "#{api_key[0..3]}#{'•' * 16}"
  end

  def masked_api_secret
    return "Not set" if api_secret.blank?
    "#{api_secret[0..3]}#{'•' * 16}"
  end
end
