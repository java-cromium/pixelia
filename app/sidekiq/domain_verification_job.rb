class DomainVerificationJob
  include Sidekiq::Job
  sidekiq_options queue: :default, retry: 5

  MAX_POLL_ATTEMPTS = 60
  POLL_INTERVAL = 60.seconds

  def perform(site_id, attempt = 1)
    site = Site.find_by(id: site_id)
    return unless site&.cf_hostname_id.present?
    return if site.domain_active?

    site.refresh_domain_status!

    if site.domain_active?
      Rails.logger.info "[DomainVerification] Site #{site.id} (#{site.custom_domain}) is now active"
      return
    end

    if attempt >= MAX_POLL_ATTEMPTS
      Rails.logger.warn "[DomainVerification] Site #{site.id} (#{site.custom_domain}) reached max poll attempts"
      return
    end

    self.class.perform_in(POLL_INTERVAL, site_id, attempt + 1)
  end
end
