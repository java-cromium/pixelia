class Portal::SitesController < Portal::BaseController
  def index
    @sites = @account.sites.order(:name)
  end

  def show
    @site = @account.sites.find(params[:id])
  end

  # POST /portal/sites/:id/generate — One-click site generator
  def generate
    @site = @account.sites.find(params[:id])
    generator = SiteGeneratorService.new(@site)
    generator.generate!
    redirect_to portal_site_path(@site), notice: "Site generated! Your one-pager is ready to customize."
  end
end
