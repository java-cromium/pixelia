class Portal::DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @client = current_user.client
    return unless @client

    @projects = @client.projects
    @stores = EcommerceStore.where(project_id: @projects.select(:id))
    @projects_by_status = @projects.group(:status).count
    @projects_by_type = @projects.group(:project_type).count
    @stores_by_platform = @stores.group(:platform).count
    @projects_timeline = @projects.group_by_month(:created_at, last: 6).count
  end
end
