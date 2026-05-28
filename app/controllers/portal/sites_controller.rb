class Portal::SitesController < Portal::BaseController
  def index
    @sites = @account.sites.order(:name)
  end

  def show
    @site = @account.sites.find(params[:id])
  end
end
