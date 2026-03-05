require "test_helper"

class Marketing::LeadsControllerTest < ActionDispatch::IntegrationTest
  test "should create lead with valid params" do
    assert_difference("Lead.count", 1) do
      post leads_url, params: {
        lead: {
          first_name: "Ana",
          email: "ana@example.com",
          project_type: "Sitio Web",
          status: "new"
        }
      }
    end
    assert_redirected_to root_url
  end

  test "should create lead and redirect with notice" do
    post leads_url, params: {
      lead: {
        first_name: "Pedro",
        email: "pedro@example.com",
        project_type: "Tienda Online (E-Commerce)",
        status: "new"
      }
    }
    assert_redirected_to root_url
    assert_equal "Thanks! We'll be in touch.", flash[:notice]
  end

  test "should redirect back on invalid lead" do
    assert_no_difference("Lead.count") do
      post leads_url, params: {
        lead: { first_name: "", email: "", project_type: "", status: "" }
      }
    end
  end
end
