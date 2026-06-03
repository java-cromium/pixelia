class Portal::SitesController < Portal::BaseController
  def index
    @sites = @account.sites.order(:name)
  end

  def show
    @site = @account.sites.find(params[:id])
  end

  # GET /portal/sites/:id/build_wizard — Multi-step wizard form
  def build_wizard
    @site = @account.sites.find(params[:id])
    @configuration = @site.configuration || @site.build_configuration(business_name: @site.name)
  end

  # POST /portal/sites/:id/generate — Save configuration and generate pages
  def generate
    @site = @account.sites.find(params[:id])
    @configuration = @site.configuration || @site.build_configuration

    cleaned_params = configuration_params
    # Remove blank gallery_images entries (browsers submit [""] for empty file inputs)
    if cleaned_params[:gallery_images].present?
      cleaned_params[:gallery_images] = cleaned_params[:gallery_images].reject(&:blank?)
      cleaned_params.delete(:gallery_images) if cleaned_params[:gallery_images].empty?
    end

    if @configuration.update(cleaned_params)
      generator = SiteGeneratorService.new(@site, @configuration)
      generator.generate!
      redirect_to portal_site_path(@site), notice: "Site generated! Your 4-page website is ready to customize."
    else
      render :build_wizard, status: :unprocessable_entity
    end
  end

  # POST /portal/sites/:id/generate_content — AI content generation for wizard
  def generate_content
    @site = @account.sites.find(params[:id])

    unless @account.ai_configured?
      return render json: { error: "AI provider not configured. Go to Settings to connect your AI account." }, status: :unprocessable_entity
    end

    section = params[:section]&.to_sym
    unless section.in?(%i[tagline value_proposition services about faqs team_info])
      return render json: { error: "Invalid section: #{params[:section]}" }, status: :bad_request
    end

    generator = ContentGeneratorService.new(@account)
    content = generator.generate(
      section: section,
      business_name: params[:business_name].presence || @site.name,
      industry: params[:industry].presence || @account.industry,
      context: {
        existing_services: params[:existing_services],
        services: params[:services_context],
        count: params[:count]&.to_i
      }
    )

    render json: { content: content, section: section }
  rescue ContentGeneratorService::GenerationError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def configuration_params
    params.require(:site_configuration).permit(
      :business_name, :industry, :tagline, :value_proposition,
      :about_content, :team_info, :video_url,
      :location_address, :location_lat, :location_lng,
      :service_area, :google_business_profile_url,
      :color_palette, :font_combo,
      :hero_image, :logo_image, gallery_images: [],
      services_list: [:name, :description],
      faqs: [:question, :answer]
    )
  end
end
