class Admin::ProjectsController < Admin::BaseController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @projects = pagy(ActsAsTenant.without_tenant { policy_scope(Project).includes(:client).order(:name) })
    authorize Project
  end

  def show
    authorize @project
    @ecommerce_stores = ActsAsTenant.without_tenant { @project.ecommerce_stores }
  end

  def new
    @project = Project.new
    authorize @project
  end

  def create
    ActsAsTenant.without_tenant do
      @project = Project.new(project_params)
      authorize @project
      if @project.save
        redirect_to admin_project_path(@project), notice: "Project created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
    authorize @project
  end

  def update
    authorize @project
    if @project.update(project_params)
      redirect_to admin_project_path(@project), notice: "Project updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @project
    @project.destroy
    redirect_to admin_projects_path, notice: "Project deleted."
  end

  private

  def set_project
    ActsAsTenant.without_tenant do
      @project = Project.find(params[:id])
    end
  end

  def project_params
    params.require(:project).permit(:name, :client_id, :project_type, :status, :launch_date)
  end
end
