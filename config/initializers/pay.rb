Pay.setup do |config|
  config.business_name = "Pixelia"
  config.business_address = "123 Main St, San Juan, PR 00901"
  config.application_name = "Pixelia"
  config.support_email = "support@pixelia.com"

  config.automount_routes = true
  config.routes_path = "/pay"
end
