class Admin::LeadsController < Admin::BaseController
  before_action :set_lead, only: [:show, :update, :destroy]

  def index
    @pagy, @leads = pagy(policy_scope(Lead).order(created_at: :desc))
    authorize Lead
  end

  def show
    authorize @lead
  end

  def update
    authorize @lead
    if @lead.update(lead_params)
      redirect_to admin_lead_path(@lead), notice: "Lead updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @lead
    @lead.destroy
    redirect_to admin_leads_path, notice: "Lead deleted."
  end

  private

  def set_lead
    @lead = Lead.find(params[:id])
  end

  def lead_params
    params.require(:lead).permit(:status)
  end
end
