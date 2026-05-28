class Portal::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account

  layout "portal"

  private

  def set_account
    @account = current_user.account
    redirect_to root_path, alert: "No account found. Please contact support." unless @account
  end
end
