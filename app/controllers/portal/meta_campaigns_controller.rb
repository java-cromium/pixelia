class Portal::MetaCampaignsController < Portal::BaseController
  before_action :require_meta_ads_connection, except: [:index]
  before_action :set_campaign, only: [:show, :edit, :update, :destroy, :sync, :pause, :enable]

  def index
    @campaigns = @account.meta_ad_campaigns.order(created_at: :desc)
    @meta_account = @account.meta_ad_account
  end

  def show
  end

  def new
    @campaign = @account.meta_ad_campaigns.new(status: "draft", objective: "OUTCOME_TRAFFIC")
  end

  def create
    @campaign = @account.meta_ad_campaigns.new(campaign_params)
    @campaign.meta_ad_account = @account.meta_ad_account
    @campaign.status = "draft"
    convert_budget_to_cents

    if @campaign.save
      redirect_to portal_meta_campaign_path(@campaign), notice: "Campaign created. Review and push to Meta when ready."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @campaign.assign_attributes(campaign_params)
    convert_budget_to_cents

    if @campaign.save
      redirect_to portal_meta_campaign_path(@campaign), notice: "Campaign updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @campaign.synced?
      begin
        service = MetaAdsService.new(@account.meta_ad_account)
        service.delete_campaign(@campaign.meta_campaign_id)
      rescue MetaAdsService::Error => e
        Rails.logger.error "[MetaAds] Failed to delete campaign remotely: #{e.message}"
      end
    end

    @campaign.update!(status: "deleted")
    redirect_to portal_meta_campaigns_path, notice: "Campaign deleted."
  end

  # Push a draft campaign to Meta Ads
  def sync
    unless @campaign.draft?
      redirect_to portal_meta_campaign_path(@campaign), alert: "Only draft campaigns can be pushed."
      return
    end

    ad_account_id = @account.meta_ad_account.meta_ad_account_id
    unless ad_account_id.present?
      redirect_to portal_meta_campaign_path(@campaign), alert: "Please select an ad account in settings first."
      return
    end

    service = MetaAdsService.new(@account.meta_ad_account)
    result = service.create_campaign(
      ad_account_id,
      {
        name: @campaign.name,
        objective: @campaign.objective,
        daily_budget_cents: @campaign.daily_budget_cents,
        lifetime_budget_cents: @campaign.lifetime_budget_cents,
        start_date: @campaign.start_date,
        end_date: @campaign.end_date
      }
    )

    @campaign.update!(
      meta_campaign_id: result[:campaign_id],
      status: "paused",
      last_synced_at: Time.current
    )

    redirect_to portal_meta_campaign_path(@campaign), notice: "Campaign pushed to Meta Ads successfully."
  rescue MetaAdsService::Error => e
    redirect_to portal_meta_campaign_path(@campaign), alert: "Meta Ads error: #{e.message}"
  end

  def pause
    service = MetaAdsService.new(@account.meta_ad_account)
    service.pause_campaign(@campaign.meta_campaign_id)
    @campaign.update!(status: "paused")
    redirect_to portal_meta_campaign_path(@campaign), notice: "Campaign paused."
  rescue MetaAdsService::Error => e
    redirect_to portal_meta_campaign_path(@campaign), alert: "Error: #{e.message}"
  end

  def enable
    service = MetaAdsService.new(@account.meta_ad_account)
    service.enable_campaign(@campaign.meta_campaign_id)
    @campaign.update!(status: "active")
    redirect_to portal_meta_campaign_path(@campaign), notice: "Campaign activated."
  rescue MetaAdsService::Error => e
    redirect_to portal_meta_campaign_path(@campaign), alert: "Error: #{e.message}"
  end

  private

  def require_meta_ads_connection
    unless @account.meta_ad_account&.connected?
      redirect_to portal_settings_path, alert: "Please connect your Meta Ads account first."
    end
  end

  def set_campaign
    @campaign = @account.meta_ad_campaigns.find(params[:id])
  end

  def campaign_params
    params.require(:meta_ad_campaign).permit(
      :name, :objective, :daily_budget_cents, :lifetime_budget_cents,
      :target_url, :start_date, :end_date
    )
  end

  # Form sends budget in dollars; convert to cents for storage + Meta Ads API
  def convert_budget_to_cents
    if params.dig(:meta_ad_campaign, :daily_budget_cents).present?
      dollars = params[:meta_ad_campaign][:daily_budget_cents].to_f
      @campaign.daily_budget_cents = (dollars * 100).to_i
    end
    if params.dig(:meta_ad_campaign, :lifetime_budget_cents).present?
      dollars = params[:meta_ad_campaign][:lifetime_budget_cents].to_f
      @campaign.lifetime_budget_cents = (dollars * 100).to_i
    end
  end
end
