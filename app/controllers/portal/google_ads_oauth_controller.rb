class Portal::GoogleAdsOauthController < Portal::BaseController
  def callback
    auth = request.env["omniauth.auth"]

    if auth.blank?
      redirect_to portal_google_campaigns_path, alert: "Google authentication failed."
      return
    end

    begin
      # Check if this is a CID connection (user entered CID manually before OAuth)
      if session[:pending_cid].present?
        customer_id = session.delete(:pending_cid)
        nickname = session.delete(:pending_cid_nickname)

        # Create CID connection with OAuth token
        google_ad_account = @account.google_ad_accounts.new(
          connection_type: "cid",
          google_customer_id: customer_id,
          nickname: nickname
        )
        google_ad_account.update_tokens!(auth)
        google_ad_account.update!(status: "connected")

        redirect_to portal_google_campaigns_path, notice: "Google Ads account (CID: #{google_ad_account.formatted_customer_id}) connected successfully."
        return
      end

      # Standard OAuth flow: discover accessible accounts
      google_ad_account = @account.google_ad_accounts.new(connection_type: "oauth")
      google_ad_account.update_tokens!(auth)

      service = GoogleAdsService.new(google_ad_account)
      customers = service.list_accessible_customers

      if customers.empty?
        google_ad_account.destroy
        redirect_to portal_google_campaigns_path, alert: "No accessible Google Ads accounts found. Please ensure your Google account has access to at least one Google Ads account."
        return
      end

      if session.delete(:create_under_mcc)
        customer_id = service.create_customer_under_mcc(@account.name)
        google_ad_account.update!(google_customer_id: customer_id, status: "connected")
        redirect_to portal_google_campaigns_path, notice: "New Google Ads account created and connected successfully."
      else
        # Use the first accessible customer
        customer_id = customers.first
        # Check if this CID is already linked
        existing = @account.google_ad_accounts.find_by(google_customer_id: customer_id.gsub("-", ""))
        if existing
          # Update the existing record with fresh tokens instead of duplicating
          existing.update_tokens!(auth)
          existing.update!(status: "connected")
          google_ad_account.destroy
          redirect_to portal_google_campaigns_path, notice: "Google Ads account reconnected successfully."
        else
          google_ad_account.update!(google_customer_id: customer_id, status: "connected")
          redirect_to portal_google_campaigns_path, notice: "Google Ads account connected successfully."
        end
      end
    rescue GoogleAdsService::Error => e
      google_ad_account&.destroy
      redirect_to portal_google_campaigns_path, alert: "Google Ads API error: #{e.message}. Please check your credentials and try again."
    rescue ActiveRecord::RecordInvalid => e
      google_ad_account&.destroy
      redirect_to portal_google_campaigns_path, alert: "Failed to connect: #{e.message}"
    end
  end

  def failure
    redirect_to portal_google_campaigns_path, alert: "Google authentication failed: #{params[:message]}"
  end

  # Connect via 10-digit CID (manual entry)
  # Stores CID in session and triggers OAuth via POST
  def connect_cid
    customer_id = params[:google_customer_id].to_s.strip
    nickname = params[:nickname].to_s.strip.presence

    # Validate CID format before starting OAuth
    unless customer_id.match?(/\A\d{3}-?\d{3}-?\d{4}\z/)
      redirect_to portal_google_campaigns_path, alert: "Invalid Customer ID format. Must be a 10-digit number (e.g., 123-456-7890)."
      return
    end

    # Store CID details in session
    session[:pending_cid] = customer_id
    session[:pending_cid_nickname] = nickname

    # Render a form that auto-submits to OmniAuth via POST
    render html: <<-HTML.html_safe
      <!DOCTYPE html>
      <html>
      <head><title>Connecting to Google Ads...</title></head>
      <body onload="document.getElementById('oauth-form').submit()">
        <form id="oauth-form" action="/auth/google_ads" method="post">
          <input type="hidden" name="authenticity_token" value="#{form_authenticity_token}">
        </form>
        <p>Connecting to Google Ads...</p>
      </body>
      </html>
    HTML
  end

  def destroy
    google_ad_account = @account.google_ad_accounts.find_by(id: params[:id])
    if google_ad_account
      google_ad_account.destroy
    end
    redirect_to portal_google_campaigns_path, notice: "Google Ads account disconnected."
  end
end
