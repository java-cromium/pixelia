class LeadMailer < ApplicationMailer
  def new_lead_notification(lead)
    @lead = lead
    mail(
      to: admin_emails,
      subject: "New Lead: #{lead.first_name} — #{lead.project_type}"
    )
  end

  def lead_confirmation(lead)
    @lead = lead
    mail(
      to: lead.email,
      subject: "Thanks for reaching out to Pixelia!"
    )
  end

  private

  def admin_emails
    User.where(role: :super_admin).pluck(:email)
  end
end
