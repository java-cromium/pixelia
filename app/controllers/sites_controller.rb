class SitesController < ApplicationController
  layout "site"

  def show
    @site = find_site
    return render_not_found unless @site&.published?

    slug = params[:slug].presence || "home"
    @page = @site.pages.published.find_by(slug: slug)
    return render_not_found unless @page
  end

  private

  def find_site
    if params[:subdomain].present?
      Site.find_by(subdomain: params[:subdomain])
    elsif params[:domain].present?
      Site.find_by(custom_domain: params[:domain])
    else
      nil
    end
  end

  def render_not_found
    render plain: "Page not found", status: :not_found
  end
end
