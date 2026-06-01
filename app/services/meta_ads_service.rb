class MetaAdsService
  class Error < StandardError; end

  API_VERSION = "v21.0"

  def initialize(meta_ad_account)
    @meta_ad_account = meta_ad_account
    @graph = Koala::Facebook::API.new(meta_ad_account.access_token)
  end

  # ── Ad Account Discovery ────────────────────────────────────────
  def list_ad_accounts
    result = @graph.get_connections("me", "adaccounts", fields: "id,name,account_status,currency,business")
    result.map do |acct|
      {
        id: acct["id"],
        name: acct["name"],
        status: acct["account_status"],
        currency: acct["currency"]
      }
    end
  rescue Koala::Facebook::ClientError, Koala::Facebook::ServerError => e
    raise Error, "Failed to list ad accounts: #{e.message}"
  end

  # ── Campaign Operations ─────────────────────────────────────────
  def list_campaigns(ad_account_id)
    result = @graph.get_connections(
      ad_account_id, "campaigns",
      fields: "id,name,objective,status,daily_budget,lifetime_budget,start_time,stop_time,created_time,updated_time"
    )
    result.map do |c|
      {
        id: c["id"],
        name: c["name"],
        objective: c["objective"],
        status: c["status"],
        daily_budget: c["daily_budget"],
        lifetime_budget: c["lifetime_budget"],
        start_time: c["start_time"],
        stop_time: c["stop_time"]
      }
    end
  rescue Koala::Facebook::ClientError, Koala::Facebook::ServerError => e
    raise Error, "Failed to list campaigns: #{e.message}"
  end

  def create_campaign(ad_account_id, params)
    campaign_params = {
      name: params[:name],
      objective: params[:objective],
      status: "PAUSED",
      special_ad_categories: []
    }

    campaign_params[:daily_budget] = params[:daily_budget_cents] if params[:daily_budget_cents]
    campaign_params[:lifetime_budget] = params[:lifetime_budget_cents] if params[:lifetime_budget_cents]

    if params[:start_date]
      campaign_params[:start_time] = params[:start_date].to_time.utc.iso8601
    end

    if params[:end_date]
      campaign_params[:end_time] = params[:end_date].to_time.utc.iso8601
    end

    result = @graph.put_connections(ad_account_id, "campaigns", campaign_params)

    { campaign_id: result["id"] }
  rescue Koala::Facebook::ClientError, Koala::Facebook::ServerError => e
    raise Error, "Failed to create campaign: #{e.message}"
  end

  def update_campaign(campaign_id, params)
    update_params = {}
    update_params[:name] = params[:name] if params[:name]
    update_params[:status] = params[:status] if params[:status]
    update_params[:daily_budget] = params[:daily_budget_cents] if params[:daily_budget_cents]
    update_params[:lifetime_budget] = params[:lifetime_budget_cents] if params[:lifetime_budget_cents]

    @graph.graph_call(campaign_id, update_params, "post")
  rescue Koala::Facebook::ClientError, Koala::Facebook::ServerError => e
    raise Error, "Failed to update campaign: #{e.message}"
  end

  def pause_campaign(campaign_id)
    update_campaign(campaign_id, status: "PAUSED")
  end

  def enable_campaign(campaign_id)
    update_campaign(campaign_id, status: "ACTIVE")
  end

  def delete_campaign(campaign_id)
    update_campaign(campaign_id, status: "DELETED")
  end

  # ── Campaign Insights ───────────────────────────────────────────
  def campaign_insights(campaign_id, date_range: "last_7d")
    result = @graph.get_connections(
      campaign_id, "insights",
      fields: "impressions,clicks,spend,cpc,ctr,reach",
      date_preset: date_range
    )
    result.first || {}
  rescue Koala::Facebook::ClientError, Koala::Facebook::ServerError => e
    raise Error, "Failed to get insights: #{e.message}"
  end
end
