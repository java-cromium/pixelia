require "test_helper"

class SiteTest < ActiveSupport::TestCase
  setup do
    @site = sites(:acme_site)
    @site_with_domain = sites(:acme_site_with_domain)
  end

  # -- Validations --

  test "valid site" do
    assert @site.valid?
  end

  test "requires name" do
    @site.name = nil
    assert_not @site.valid?
    assert_includes @site.errors[:name], "can't be blank"
  end

  test "subdomain must be unique" do
    duplicate = @site.dup
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:subdomain], "has already been taken"
  end

  test "subdomain format rejects uppercase" do
    @site.subdomain = "ACME"
    assert_not @site.valid?
  end

  test "subdomain format rejects spaces" do
    @site.subdomain = "my site"
    assert_not @site.valid?
  end

  test "custom_domain format rejects invalid domains" do
    @site.custom_domain = "not a domain"
    assert_not @site.valid?
    assert_includes @site.errors[:custom_domain], "must be a valid domain"
  end

  test "custom_domain format accepts valid domains" do
    @site.custom_domain = "www.example.com"
    assert @site.valid?
  end

  test "custom_domain allows blank" do
    @site.custom_domain = ""
    assert @site.valid?
  end

  # -- Domain status helpers --

  test "domain_display returns custom_domain when present" do
    assert_equal "shop.acme.com", @site_with_domain.domain_display
  end

  test "domain_display returns subdomain fallback" do
    assert_equal "acme.pixelia.com", @site.domain_display
  end

  test "domain_display returns nil when no domain info" do
    @site.subdomain = nil
    @site.custom_domain = nil
    assert_nil @site.domain_display
  end

  test "domain_active? is true when both statuses are active" do
    @site_with_domain.domain_status = "active"
    @site_with_domain.ssl_status = "active"
    assert @site_with_domain.domain_active?
  end

  test "domain_active? is false when domain_status is pending" do
    @site_with_domain.domain_status = "pending"
    @site_with_domain.ssl_status = "active"
    assert_not @site_with_domain.domain_active?
  end

  test "domain_pending? is true when cf_hostname_id present but not active" do
    assert @site_with_domain.domain_pending?
  end

  test "domain_pending? is false when no cf_hostname_id" do
    assert_not @site.domain_pending?
  end

  test "domain_configured? is true when cf_hostname_id present" do
    assert @site_with_domain.domain_configured?
  end

  test "domain_configured? is false when no cf_hostname_id" do
    assert_not @site.domain_configured?
  end

  # -- Scopes --

  test "published scope returns only published sites" do
    published = Site.published
    assert_includes published, @site
    assert_not_includes published, sites(:globex_site)
  end

  test "pending_verification scope returns pending domain sites" do
    pending = Site.pending_verification
    assert_includes pending, @site_with_domain
    assert_not_includes pending, @site
  end
end
