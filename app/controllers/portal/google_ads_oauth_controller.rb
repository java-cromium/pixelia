class Portal::GoogleAdsOauthController < Portal::BaseController
  def callback
    auth = request.env["omniauth.auth"]

    if auth.blank?
      redirect_to portal_settings_path, alert: "Google authentication failed."
      return
    end

    google_account = @account.google_ad_account || @account.build_google_ad_account
    google_account.update_tokens!(auth)

    redirect_to portal_settings_path, notice: "Google Ads account connected successfully."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to portal_settings_path, alert: "Failed to connect: #{e.message}"
  end

  def failure
    redirect_to portal_settings_path, alert: "Google authentication failed: #{params[:message]}"
  end

  def destroy
    google_account = @account.google_ad_account
    if google_account
      google_account.update!(status: "disconnected", access_token: nil, refresh_token: nil)
    end
    redirect_to portal_settings_path, notice: "Google Ads account disconnected."
  end
end
