Rails.application.config.cloudflare = ActiveSupport::OrderedOptions.new.tap do |cf|
  cf.api_token   = ENV.fetch("CLOUDFLARE_API_TOKEN", "")
  cf.zone_id     = ENV.fetch("CLOUDFLARE_ZONE_ID", "")
  cf.cname_target = ENV.fetch("CLOUDFLARE_CNAME_TARGET", "customers.pixelia.com")
end
