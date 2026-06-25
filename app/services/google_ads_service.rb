require 'google/ads/google_ads'

class GoogleAdsService
  class Error < StandardError; end
  class AuthError < Error; end

  def initialize(google_ad_account)
    @google_ad_account = google_ad_account
    @config = Rails.application.config.google_ads
  end

  # Build a configured Google Ads API client for this account
  # For OAuth connections, uses the user's refresh_token
  # For CID connections, uses the MCC's refresh_token for management access
  def client
    @client ||= begin
      token = resolve_refresh_token
      raise AuthError, "No refresh token available. Please reconnect this Google Ads account via OAuth." if token.blank?

      Google::Ads::GoogleAds::GoogleAdsClient.new do |c|
        c.developer_token = @config.developer_token
        c.client_id = @config.client_id
        c.client_secret = @config.client_secret
        c.refresh_token = token
        c.login_customer_id = @config.login_customer_id.presence
      end
    end
  rescue AuthError
    raise
  rescue => e
    raise AuthError, "Failed to initialize Google Ads client: #{e.message}"
  end

  # Create a new customer account under the Pixelia MCC
  def create_customer_under_mcc(business_name)
    mcc_id = @config.login_customer_id.to_s.gsub("-", "")
    raise Error, "MCC Login Customer ID not configured" if mcc_id.blank?

    operation = client.operation.create_resource.customer do |customer|
      customer.descriptive_name = business_name
      customer.currency_code = "USD"
      customer.time_zone = "America/New_York"
    end

    response = client.service.customer.create_customer_client(
      customer_id: mcc_id,
      customer_client: operation
    )

    # Extract the new customer ID from the resource name
    response.resource_name.split("/").last
  rescue Google::Ads::GoogleAds::Errors::GoogleAdsError => e
    raise Error, extract_error(e)
  end

  # List accessible customer accounts
  def list_accessible_customers
    # Use GAQL query to list customer accounts instead of list_accessible_customers
    # which may have compatibility issues in newer API versions
    query = <<~GAQL
      SELECT
        customer_client.id,
        customer_client.descriptive_name
      FROM customer_client
      WHERE customer_client.status = 'ENABLED'
        AND customer_client.manager = FALSE
    GAQL

    response = client.service.google_ads.search(
      customer_id: @config.login_customer_id.to_s.gsub("-", ""),
      query: query
    )

    response.map { |row| row.customer_client.id.to_s }
  rescue Google::Ads::GoogleAds::Errors::GoogleAdsError => e
    raise Error, extract_error(e)
  end

  # Fetch campaigns from Google Ads
  def list_campaigns(customer_id)
    query = <<~GAQL
      SELECT
        campaign.id,
        campaign.name,
        campaign.status,
        campaign.advertising_channel_type,
        campaign_budget.amount_micros,
        campaign.start_date,
        campaign.end_date,
        metrics.impressions,
        metrics.clicks,
        metrics.cost_micros,
        metrics.conversions
      FROM campaign
      WHERE campaign.status != 'REMOVED'
      ORDER BY campaign.name
    GAQL

    response = client.service.google_ads.search(
      customer_id: customer_id.to_s.gsub("-", ""),
      query: query
    )

    response.map do |row|
      {
        id: row.campaign.id.to_s,
        name: row.campaign.name,
        status: row.campaign.status.to_s.downcase,
        channel_type: row.campaign.advertising_channel_type.to_s.downcase,
        budget_micros: row.campaign_budget.amount_micros,
        start_date: row.campaign.start_date,
        end_date: row.campaign.end_date,
        impressions: row.metrics.impressions,
        clicks: row.metrics.clicks,
        cost_micros: row.metrics.cost_micros,
        conversions: row.metrics.conversions
      }
    end
  rescue Google::Ads::GoogleAds::Errors::GoogleAdsError => e
    raise Error, extract_error(e)
  end

  # Fetch metrics for a specific campaign
  def get_campaign_metrics(customer_id, campaign_id)
    query = <<~GAQL
      SELECT
        metrics.impressions,
        metrics.clicks,
        metrics.cost_micros,
        metrics.conversions
      FROM campaign
      WHERE campaign.id = #{campaign_id}
    GAQL

    response = client.service.google_ads.search(
      customer_id: customer_id.to_s.gsub("-", ""),
      query: query
    )

    row = response.first
    return nil unless row

    {
      impressions: row.metrics.impressions,
      clicks: row.metrics.clicks,
      cost_micros: row.metrics.cost_micros,
      conversions: row.metrics.conversions
    }
  rescue Google::Ads::GoogleAds::Errors::GoogleAdsError => e
    raise Error, extract_error(e)
  end

  # Create a new campaign in Google Ads
  def create_campaign(customer_id, params)
    customer_id = customer_id.to_s.gsub("-", "")

    # 1. Create a campaign budget
    budget_operation = client.operation.create_resource.campaign_budget do |budget|
      budget.name = "Budget for #{params[:name]} #{SecureRandom.hex(4)}"
      budget.amount_micros = params[:budget_amount_micros].to_i
      budget.delivery_method = :STANDARD
      budget.period = :DAILY
    end

    budget_service = client.service.campaign_budget
    budget_response = budget_service.mutate_campaign_budgets(
      customer_id: customer_id,
      operations: [budget_operation]
    )
    budget_resource = budget_response.results.first.resource_name

    # 2. Create the campaign
    campaign_operation = client.operation.create_resource.campaign do |campaign|
      campaign.name = params[:name]
      campaign.campaign_budget = budget_resource
      campaign.advertising_channel_type = channel_type_enum(params[:campaign_type])
      campaign.status = :PAUSED
      campaign.start_date = params[:start_date]&.strftime("%Y%m%d") if params[:start_date]
      campaign.end_date = params[:end_date]&.strftime("%Y%m%d") if params[:end_date]

      if params[:target_url].present?
        campaign.final_url_suffix = params[:target_url]
      end
    end

    campaign_service = client.service.campaign
    campaign_response = campaign_service.mutate_campaigns(
      customer_id: customer_id,
      operations: [campaign_operation]
    )

    campaign_resource = campaign_response.results.first.resource_name
    campaign_id = campaign_resource.split("/").last

    { campaign_id: campaign_id, resource_name: campaign_resource }
  rescue Google::Ads::GoogleAds::Errors::GoogleAdsError => e
    raise Error, extract_error(e)
  end

  # Pause a campaign
  def pause_campaign(customer_id, campaign_id)
    update_campaign_status(customer_id, campaign_id, :PAUSED)
  end

  # Enable a campaign
  def enable_campaign(customer_id, campaign_id)
    update_campaign_status(customer_id, campaign_id, :ENABLED)
  end

  # Remove a campaign
  def remove_campaign(customer_id, campaign_id)
    customer_id = customer_id.to_s.gsub("-", "")
    operation = client.operation.remove_resource.campaign(
      "customers/#{customer_id}/campaigns/#{campaign_id}"
    )

    campaign_service = client.service.campaign
    campaign_service.mutate_campaigns(
      customer_id: customer_id,
      operations: [operation]
    )
    true
  rescue Google::Ads::GoogleAds::Errors::GoogleAdsError => e
    raise Error, extract_error(e)
  end

  private

  # Resolve the best available refresh token for API authentication.
  # Priority: account's own token > MCC global token
  def resolve_refresh_token
    # Always prefer the account's own refresh token (set via OAuth flow)
    return @google_ad_account.refresh_token if @google_ad_account.refresh_token.present?

    # Fallback: for CID connections, try to find an OAuth-connected account
    # from the same Pixelia account that has a valid refresh token
    if @google_ad_account.cid?
      oauth_account = @google_ad_account.account.google_ad_accounts
        .by_oauth.connected
        .where.not(refresh_token: [nil, ""])
        .first
      return oauth_account.refresh_token if oauth_account&.refresh_token.present?
    end

    # Last resort: global MCC refresh token
    @config.mcc_refresh_token.presence
  end

  def update_campaign_status(customer_id, campaign_id, status)
    customer_id = customer_id.to_s.gsub("-", "")
    operation = client.operation.update_resource.campaign(
      "customers/#{customer_id}/campaigns/#{campaign_id}"
    ) do |campaign|
      campaign.status = status
    end

    campaign_service = client.service.campaign
    campaign_service.mutate_campaigns(
      customer_id: customer_id,
      operations: [operation]
    )
    true
  rescue Google::Ads::GoogleAds::Errors::GoogleAdsError => e
    raise Error, extract_error(e)
  end

  def channel_type_enum(type)
    case type.to_s
    when "search"          then :SEARCH
    when "display"         then :DISPLAY
    when "shopping"        then :SHOPPING
    when "performance_max" then :PERFORMANCE_MAX
    else :SEARCH
    end
  end

  def extract_error(error)
    messages = error.failure&.errors&.map { |e| e.message } || [error.message]
    messages.join(", ")
  end
end
