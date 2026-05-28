class Portal::DomainsController < Portal::BaseController
  before_action :set_site

  def show
    # Displayed inline on the site show page; this action handles
    # refresh-status AJAX requests
    @site.refresh_domain_status! if @site.domain_configured?
    redirect_to portal_site_path(@site), notice: "Domain status refreshed."
  end

  def create
    hostname = domain_params[:custom_domain]&.strip&.downcase

    if hostname.blank?
      redirect_to portal_site_path(@site), alert: "Please enter a domain."
      return
    end

    if @site.domain_configured?
      redirect_to portal_site_path(@site), alert: "A custom domain is already configured. Remove it first."
      return
    end

    @site.provision_custom_domain!(hostname)
    redirect_to portal_site_path(@site), notice: "Custom domain #{hostname} has been submitted. Follow the DNS instructions below."
  rescue CloudflareDomainService::Error => e
    redirect_to portal_site_path(@site), alert: "Cloudflare error: #{e.message}"
  end

  def destroy
    @site.remove_custom_domain!
    redirect_to portal_site_path(@site), notice: "Custom domain removed."
  rescue CloudflareDomainService::Error => e
    redirect_to portal_site_path(@site), alert: "Cloudflare error: #{e.message}"
  end

  private

  def set_site
    @site = @account.sites.find(params[:site_id])
  end

  def domain_params
    params.require(:domain).permit(:custom_domain)
  end
end
