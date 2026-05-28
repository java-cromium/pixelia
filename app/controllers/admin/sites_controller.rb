class Admin::SitesController < Admin::BaseController
  before_action :set_site, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @sites = pagy(policy_scope(Site).includes(:account, :pages).order(created_at: :desc))
    authorize Site
  end

  def show
    authorize @site
    @pages = @site.pages.ordered
  end

  def new
    @site = Site.new
    authorize @site
    @accounts = Account.order(:name)
  end

  def create
    @site = Site.new(site_params)
    authorize @site
    if @site.save
      redirect_to admin_site_path(@site), notice: "Site created successfully."
    else
      @accounts = Account.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @site
    @accounts = Account.order(:name)
  end

  def update
    authorize @site
    if @site.update(site_params)
      redirect_to admin_site_path(@site), notice: "Site updated successfully."
    else
      @accounts = Account.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @site
    @site.destroy
    redirect_to admin_sites_path, notice: "Site deleted."
  end

  private

  def set_site
    @site = Site.find(params[:id])
  end

  def site_params
    params.require(:site).permit(:account_id, :name, :subdomain, :custom_domain, :published)
  end
end
