class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  set_current_tenant_through_filter
  before_action :set_tenant

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def set_tenant
    if current_user&.client
      set_current_tenant(current_user.client)
    end
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end
end
