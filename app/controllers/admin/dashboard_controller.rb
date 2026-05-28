class Admin::DashboardController < Admin::BaseController
  def index
    @accounts_count = Account.count
    @users_count    = User.count
    @leads_count    = Lead.count
    @stores_count   = ActsAsTenant.without_tenant { EcommerceStore.count }
    @sites_count    = Site.count
    @recent_leads   = Lead.order(created_at: :desc).limit(5)

    @leads_by_month     = Lead.group_by_month(:created_at, last: 6).count
    @leads_by_type      = Lead.group(:project_type).count
    @stores_by_platform = ActsAsTenant.without_tenant { EcommerceStore.group(:platform).count }
    @users_by_month     = User.group_by_month(:created_at, last: 6).count
  end
end
