class Admin::DashboardController < Admin::BaseController
  def index
    @clients_count  = Client.count
    @users_count    = User.count
    @projects_count = ActsAsTenant.without_tenant { Project.count }
    @leads_count    = Lead.count
    @stores_count   = ActsAsTenant.without_tenant { EcommerceStore.count }
    @recent_leads   = Lead.order(created_at: :desc).limit(5)

    @leads_by_month    = Lead.group_by_month(:created_at, last: 6).count
    @leads_by_type     = Lead.group(:project_type).count
    @projects_by_status = ActsAsTenant.without_tenant { Project.group(:status).count }
    @users_by_month    = User.group_by_month(:created_at, last: 6).count
  end
end
