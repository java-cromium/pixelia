class Portal::DashboardController < Portal::BaseController
  def index
    @stores = @account.ecommerce_stores
    @sites = @account.sites
    @stores_by_platform = @stores.group(:platform).count
  end
end
