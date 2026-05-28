class Admin::PagesController < Admin::BaseController
  skip_before_action :verify_authenticity_token, only: [:content]
  before_action :set_site
  before_action :set_page, only: [:edit, :update, :destroy, :editor, :content]

  def new
    @page = @site.pages.build
    authorize @page
  end

  def create
    @page = @site.pages.build(page_params)
    authorize @page
    if @page.save
      redirect_to editor_admin_site_page_path(@site, @page), notice: "Page created. Start building!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @page
  end

  def update
    authorize @page
    if @page.update(page_params)
      redirect_to admin_site_path(@site), notice: "Page updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @page
    @page.destroy
    redirect_to admin_site_path(@site), notice: "Page deleted."
  end

  # GET /admin/sites/:site_id/pages/:id/editor — GrapeJS editor view
  def editor
    authorize @page, :update?
    render layout: "editor"
  end

  # GET/PUT /admin/sites/:site_id/pages/:id/content — GrapeJS storage API
  def content
    authorize @page, :update?

    if request.get?
      render json: @page.content || {}
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
    @site = Site.find(params[:site_id])
  end

  def set_page
    @page = @site.pages.find(params[:id])
  end

  def page_params
    params.require(:page).permit(:title, :slug, :status, :position)
  end
end
