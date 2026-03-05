class Portal::ProjectsController < ApplicationController
  before_action :authenticate_user!

  def index
    @pagy, @projects = pagy(policy_scope(Project))
  end

  def show
    @project = Project.find(params[:id])
    authorize @project
  end
end
