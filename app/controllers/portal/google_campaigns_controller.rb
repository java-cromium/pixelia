class Portal::GoogleCampaignsController < Portal::BaseController
  before_action :require_google_ads_connection, except: [:index]
  before_action :set_campaign, only: [:show, :edit, :update, :destroy, :sync, :pause, :enable, :sync_metrics]

  def index
    @campaigns = @account.google_ad_campaigns.order(created_at: :desc)
    @google_accounts = @account.google_ad_accounts.connected
    @connected = @google_accounts.any?
  end

  def show
  end

  def new
    @campaign = @account.google_ad_campaigns.new(status: "draft", campaign_type: "search")
  end

  def create
    @campaign = @account.google_ad_campaigns.new(campaign_params)
    @campaign.google_ad_account = selected_google_account
    @campaign.status = "draft"
    convert_budget_to_micros

    if @campaign.save
      redirect_to portal_google_campaign_path(@campaign), notice: "Campaign created. Review and push to Google Ads when ready."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @campaign.assign_attributes(campaign_params)
    convert_budget_to_micros

    if @campaign.save
      redirect_to portal_google_campaign_path(@campaign), notice: "Campaign updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @campaign.synced?
      begin
        service = GoogleAdsService.new(@campaign.google_ad_account)
        service.remove_campaign(@campaign.google_ad_account.google_customer_id, @campaign.google_campaign_id)
      rescue GoogleAdsService::Error => e
        Rails.logger.error "[GoogleAds] Failed to remove campaign remotely: #{e.message}"
      end
    end

    @campaign.update!(status: "removed")
    redirect_to portal_google_campaigns_path, notice: "Campaign removed."
  end

  # Push a draft campaign to Google Ads
  def sync
    unless @campaign.draft?
      redirect_to portal_google_campaign_path(@campaign), alert: "Only draft campaigns can be pushed."
      return
    end

    ga_account = @campaign.google_ad_account
    service = GoogleAdsService.new(ga_account)
    result = service.create_campaign(
      ga_account.google_customer_id,
      {
        name: @campaign.name,
        campaign_type: @campaign.campaign_type,
        budget_amount_micros: @campaign.budget_amount_micros,
        start_date: @campaign.start_date,
        end_date: @campaign.end_date,
        target_url: @campaign.target_url
      }
    )

    @campaign.update!(
      google_campaign_id: result[:campaign_id],
      status: "paused",
      last_synced_at: Time.current
    )

    redirect_to portal_google_campaign_path(@campaign), notice: "Campaign pushed to Google Ads successfully."
  rescue GoogleAdsService::AuthError => e
    redirect_to portal_google_campaign_path(@campaign), alert: "Authentication error: #{e.message}. Please reconnect your Google Ads account."
  rescue GoogleAdsService::Error => e
    redirect_to portal_google_campaign_path(@campaign), alert: "Google Ads error: #{e.message}"
  end

  def pause
    ga_account = @campaign.google_ad_account
    service = GoogleAdsService.new(ga_account)
    service.pause_campaign(ga_account.google_customer_id, @campaign.google_campaign_id)
    @campaign.update!(status: "paused")
    redirect_to portal_google_campaign_path(@campaign), notice: "Campaign paused."
  rescue GoogleAdsService::Error => e
    redirect_to portal_google_campaign_path(@campaign), alert: "Error: #{e.message}"
  end

  def enable
    ga_account = @campaign.google_ad_account
    service = GoogleAdsService.new(ga_account)
    service.enable_campaign(ga_account.google_customer_id, @campaign.google_campaign_id)
    @campaign.update!(status: "enabled")
    redirect_to portal_google_campaign_path(@campaign), notice: "Campaign enabled."
  rescue GoogleAdsService::Error => e
    redirect_to portal_google_campaign_path(@campaign), alert: "Error: #{e.message}"
  end

  def sync_metrics
    unless @campaign.synced?
      redirect_to portal_google_campaign_path(@campaign), alert: "Cannot sync metrics for draft campaigns."
      return
    end

    ga_account = @campaign.google_ad_account
    service = GoogleAdsService.new(ga_account)
    metrics = service.get_campaign_metrics(ga_account.google_customer_id, @campaign.google_campaign_id)

    if metrics
      @campaign.update!(
        impressions: metrics[:impressions],
        clicks: metrics[:clicks],
        cost_micros: metrics[:cost_micros],
        conversions: metrics[:conversions],
        metrics_synced_at: Time.current
      )
      redirect_to portal_google_campaign_path(@campaign), notice: "Campaign metrics synced successfully."
    else
      redirect_to portal_google_campaign_path(@campaign), alert: "No metrics data available."
    end
  rescue GoogleAdsService::Error => e
    redirect_to portal_google_campaign_path(@campaign), alert: "Error syncing metrics: #{e.message}"
  end

  private

  def require_google_ads_connection
    unless @account.google_ad_accounts.connected.any?
      redirect_to portal_google_campaigns_path, alert: "Please connect your Google Ads account first."
    end
  end

  def selected_google_account
    if params.dig(:google_ad_campaign, :google_ad_account_id).present?
      @account.google_ad_accounts.connected.find(params[:google_ad_campaign][:google_ad_account_id])
    else
      @account.google_ad_accounts.connected.first
    end
  end

  def set_campaign
    @campaign = @account.google_ad_campaigns.find(params[:id])
  end

  def campaign_params
    params.require(:google_ad_campaign).permit(
      :name, :campaign_type, :budget_amount_micros,
      :target_url, :start_date, :end_date, :google_ad_account_id
    )
  end

  # Form sends budget in dollars; convert to micros for storage + Google Ads API
  def convert_budget_to_micros
    if params.dig(:google_ad_campaign, :budget_amount_micros).present?
      dollars = params[:google_ad_campaign][:budget_amount_micros].to_f
      @campaign.budget_amount_micros = (dollars * 1_000_000).to_i
    end
  end
end
