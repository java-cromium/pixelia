require "test_helper"

class Marketing::PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get root_url
    assert_response :success
  end

  test "should get services" do
    get services_url
    assert_response :success
  end

  test "should get contact" do
    get contact_url
    assert_response :success
  end

  test "should get servicio diseno web" do
    get servicios_diseno_web_url
    assert_response :success
  end

  test "should get servicio ecommerce" do
    get servicios_ecommerce_url
    assert_response :success
  end

  test "should get servicio gestion integral" do
    get servicios_gestion_integral_url
    assert_response :success
  end
end
