class Portal::PagesController < Portal::BaseController
  skip_before_action :verify_authenticity_token, only: [:content]
  before_action :set_site
  before_action :set_page, only: [:show, :edit, :update, :destroy, :editor, :content]

  def index
    redirect_to portal_site_path(@site)
  end

  def show
    redirect_to editor_portal_site_page_path(@site, @page)
  end

  def new
    @page = @site.pages.build
  end

  def create
    @page = @site.pages.build(page_params)
    if @page.save
      redirect_to editor_portal_site_page_path(@site, @page), notice: "Page created. Start building!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @page = @site.pages.find(params[:id])
  end

  def update
    if @page.update(page_params)
      redirect_to portal_site_path(@site), notice: "Page updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @page.destroy
    redirect_to portal_site_path(@site), notice: "Page deleted."
  end

  # GET /portal/sites/:site_id/pages/:id/editor
  def editor
    render layout: "editor"
  end

  # GET/PUT /portal/sites/:site_id/pages/:id/content
  def content
    if request.get?
      # If GrapeJS content is empty but we have generated HTML/CSS, return those for import
      if @page.content.blank? && @page.html_content.present?
        render json: { html: @page.html_content, css: @page.css_content }
      else
        render json: @page.content || {}
      end
    elsif request.put? || request.patch?
      content_data = params[:data] || {}
      pages_html = params[:pagesHtml]

      html_content = nil
      css_content = nil
      if pages_html.present? && pages_html.is_a?(Array) && pages_html.first
        html_content = pages_html.first[:html] || pages_html.first["html"]
        css_content = pages_html.first[:css] || pages_html.first["css"]
      end

      if @page.update(content: content_data, html_content: html_content, css_content: css_content)
        head :ok
      else
        head :unprocessable_entity
      end
    end
  end

  private

  def set_site
    @site = @account.sites.find(params[:site_id])
  end

  def set_page
    @page = @site.pages.find(params[:id])
  end

  def page_params
    params.require(:page).permit(:title, :slug, :status, :position)
  end
end
