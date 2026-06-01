Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
    ENV.fetch("GOOGLE_CLIENT_ID", ""),
    ENV.fetch("GOOGLE_CLIENT_SECRET", ""),
    {
      scope: "email,profile,https://www.googleapis.com/auth/adwords",
      access_type: "offline",
      prompt: "consent",
      name: "google_ads"
    }

  provider :facebook,
    ENV.fetch("META_APP_ID", ""),
    ENV.fetch("META_APP_SECRET", ""),
    {
      scope: "ads_management,ads_read,business_management,email",
      display: "popup",
      auth_type: "rerequest",
      name: "meta_ads"
    }
end

OmniAuth.config.allowed_request_methods = [:post]
OmniAuth.config.silence_get_warning = true
