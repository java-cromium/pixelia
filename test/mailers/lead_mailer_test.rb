require "test_helper"

class LeadMailerTest < ActionMailer::TestCase
  setup do
    @lead = leads(:new_lead)
    @admin = users(:admin)
  end

  test "new_lead_notification sends to admin emails" do
    email = LeadMailer.new_lead_notification(@lead)

    assert_emails 1 do
      email.deliver_now
    end

    assert_includes email.to, @admin.email
    assert_equal "noreply@pixelia.com", email.from.first
    assert_includes email.subject, @lead.first_name
    assert_includes email.subject, @lead.project_type
  end

  test "lead_confirmation sends to lead email" do
    email = LeadMailer.lead_confirmation(@lead)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@lead.email], email.to
    assert_equal "noreply@pixelia.com", email.from.first
    assert_equal "Thanks for reaching out to Pixelia!", email.subject
  end
end
