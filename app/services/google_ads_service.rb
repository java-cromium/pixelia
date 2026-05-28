class GoogleAdsService
  class Error < StandardError; end
  class AuthError < Error; end

  def initialize(google_ad_account)
    @google_ad_account = google_ad_account
    @config = Rails.application.config.google_ads
  end

  # Build a configured Google Ads API client for this account
  def client
    @client ||= Google::Ads::GoogleAds::GoogleAdsClient.new do |c|
      c.developer_token = @config.developer_token
      c.client_id = @config.client_id
      c.client_secret = @config.client_secret
      c.refresh_token = @google_ad_account.refresh_token
      c.login_customer_id = @config.login_customer_id.presence
    end
  rescue => e
    raise AuthError, "Failed to initialize Google Ads client: #{e.message}"
  end

  # List accessible customer accounts
  def list_accessible_customers
    service = client.service.customer
    response = service.list_accessible_customers
    response.resource_names.map { |name| name.split("/").last }
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

  # Create a new campaign in Google Ads
  def create_campaign(customer_id, params)
    customer_id = customer_id.to_s.gsub("-", "")

    # 1. Create a campaign budget
    budget_operation = client.operation.create_resource.campaign_budget do |budget|
      budget.name = "Budget for #{params[:name]} #{SecureRandom.hex(4)}"
      budget.amount_micros = params[:budget_amount_micros].to_i
      budget.delivery_method = :STANDARD
    end

    budget_response = client.service.campaign_budget.mutate_campaign_budgets(
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

    campaign_response = client.service.campaign.mutate_campaigns(
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

    client.service.campaign.mutate_campaigns(
      customer_id: customer_id,
      operations: [operation]
    )
    true
  rescue Google::Ads::GoogleAds::Errors::GoogleAdsError => e
    raise Error, extract_error(e)
  end

  private

  def update_campaign_status(customer_id, campaign_id, status)
    customer_id = customer_id.to_s.gsub("-", "")
    operation = client.operation.update_resource.campaign(
      "customers/#{customer_id}/campaigns/#{campaign_id}"
    ) do |campaign|
      campaign.status = status
    end

    client.service.campaign.mutate_campaigns(
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
