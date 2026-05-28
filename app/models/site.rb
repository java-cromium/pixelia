class Site < ApplicationRecord
  belongs_to :account
  has_many :pages, dependent: :destroy

  validates :name, presence: true
  validates :subdomain, uniqueness: true, allow_blank: true,
    format: { with: /\A[a-z0-9]([a-z0-9\-]*[a-z0-9])?\z/, message: "only lowercase letters, numbers, and hyphens" }
  validates :custom_domain, uniqueness: true, allow_blank: true,
    format: { with: /\A([a-z0-9]([a-z0-9\-]*[a-z0-9])?\.)+[a-z]{2,}\z/i, message: "must be a valid domain" }, if: -> { custom_domain.present? }

  scope :published, -> { where(published: true) }
  scope :pending_verification, -> { where(domain_status: %w[pending moved]) }

  # Domain status constants (from Cloudflare)
  DOMAIN_STATUSES = %w[pending active moved deleted].freeze
  SSL_STATUSES    = %w[initializing pending_validation pending_issuance pending_deployment active].freeze

  def domain_display
    custom_domain.presence || (subdomain.present? ? "#{subdomain}.pixelia.com" : nil)
  end

  def domain_active?
    domain_status == "active" && ssl_status == "active"
  end

  def domain_pending?
    cf_hostname_id.present? && !domain_active?
  end

  def domain_configured?
    cf_hostname_id.present?
  end

  def cname_target
    Rails.application.config.cloudflare.cname_target
  end

  # Provision a custom hostname via Cloudflare for SaaS
  def provision_custom_domain!(hostname)
    service = CloudflareDomainService.new
    result  = service.create_custom_hostname(hostname)
    status  = CloudflareDomainService.extract_status(result)

    update!(
      custom_domain: hostname,
      cf_hostname_id: result["id"],
      domain_status: status[:domain_status],
      ssl_status: status[:ssl_status],
      domain_verification_token: status[:verification_token],
      domain_verification_errors: status[:verification_errors]
    )

    DomainVerificationJob.perform_in(30.seconds, id)
    self
  end

  # Refresh domain status from Cloudflare
  def refresh_domain_status!
    return unless cf_hostname_id.present?

    service = CloudflareDomainService.new
    result  = service.get_custom_hostname(cf_hostname_id)
    status  = CloudflareDomainService.extract_status(result)

    update!(
      domain_status: status[:domain_status],
      ssl_status: status[:ssl_status],
      domain_verification_token: status[:verification_token],
      domain_verification_errors: status[:verification_errors]
    )

    self
  end

  # Remove custom hostname from Cloudflare and clear local fields
  def remove_custom_domain!
    if cf_hostname_id.present?
      service = CloudflareDomainService.new
      service.delete_custom_hostname(cf_hostname_id)
    end

    update!(
      custom_domain: nil,
      cf_hostname_id: nil,
      domain_status: nil,
      ssl_status: nil,
      domain_verification_token: nil,
      domain_verification_errors: []
    )

    self
  end
end
