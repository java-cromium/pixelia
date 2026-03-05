class Marketing::LeadsController < ApplicationController
  def create
    @lead = Lead.new(lead_params)
    if @lead.save
      LeadMailer.new_lead_notification(@lead).deliver_later
      LeadMailer.lead_confirmation(@lead).deliver_later
      redirect_back fallback_location: marketing_root_url(subdomain: "www"), notice: "Thanks! We'll be in touch."
    else
      redirect_back fallback_location: marketing_root_url(subdomain: "www"), alert: "Please check your submission."
    end
  end

  private

  def lead_params
    params.require(:lead).permit(:first_name, :email, :project_type, :status)
  end
end
