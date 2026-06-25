Rails.application.config.google_ads = ActiveSupport::OrderedOptions.new.tap do |ga|
  ga.developer_token = ENV.fetch("GOOGLE_ADS_DEVELOPER_TOKEN", "")
  ga.client_id       = ENV.fetch("GOOGLE_CLIENT_ID", "")
  ga.client_secret   = ENV.fetch("GOOGLE_CLIENT_SECRET", "")
  ga.login_customer_id = ENV.fetch("GOOGLE_ADS_LOGIN_CUSTOMER_ID", "")
  ga.mcc_refresh_token = ENV.fetch("GOOGLE_ADS_MCC_REFRESH_TOKEN", "")
end
