class Portal::MetaAdsOauthController < Portal::BaseController
  def callback
    auth = request.env["omniauth.auth"]

    if auth.blank?
      redirect_to portal_settings_path, alert: "Meta authentication failed."
      return
    end

    meta_account = @account.meta_ad_account || @account.build_meta_ad_account
    meta_account.update_tokens!(auth)

    redirect_to portal_settings_path, notice: "Meta Ads account connected successfully."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to portal_settings_path, alert: "Failed to connect: #{e.message}"
  end

  def failure
    redirect_to portal_settings_path, alert: "Meta authentication failed: #{params[:message]}"
  end

  def destroy
    meta_account = @account.meta_ad_account
    if meta_account
      meta_account.update!(status: "disconnected", access_token: nil)
    end
    redirect_to portal_settings_path, notice: "Meta Ads account disconnected."
  end
end
