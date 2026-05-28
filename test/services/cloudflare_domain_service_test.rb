require "test_helper"

class CloudflareDomainServiceTest < ActiveSupport::TestCase
  setup do
    @service = CloudflareDomainService.new
  end

  test "extract_status parses Cloudflare result correctly" do
    result = {
      "status" => "active",
      "ssl" => {
        "status" => "active",
        "validation_records" => [
          { "txt_name" => "_cf-custom-hostname.example.com" }
        ]
      },
      "verification_errors" => []
    }

    status = CloudflareDomainService.extract_status(result)

    assert_equal "active", status[:domain_status]
    assert_equal "active", status[:ssl_status]
    assert_equal "_cf-custom-hostname.example.com", status[:verification_token]
    assert_equal [], status[:verification_errors]
  end

  test "extract_status handles missing ssl block" do
    result = {
      "status" => "pending",
      "ssl" => nil,
      "verification_errors" => ["DNS not configured"]
    }

    status = CloudflareDomainService.extract_status(result)

    assert_equal "pending", status[:domain_status]
    assert_nil status[:ssl_status]
    assert_nil status[:verification_token]
    assert_equal ["DNS not configured"], status[:verification_errors]
  end

  test "extract_status handles empty verification_errors" do
    result = {
      "status" => "pending",
      "ssl" => { "status" => "initializing" }
    }

    status = CloudflareDomainService.extract_status(result)
    assert_equal [], status[:verification_errors]
  end

  test "cname_target returns configured target" do
    assert_equal Rails.application.config.cloudflare.cname_target, @service.cname_target
  end
end
