class CloudflareDomainService
  include HTTParty
  base_uri "https://api.cloudflare.com/client/v4"

  class Error < StandardError; end

  def initialize
    @zone_id     = Rails.application.config.cloudflare.zone_id
    @cname_target = Rails.application.config.cloudflare.cname_target
    @headers     = {
      "Authorization" => "Bearer #{Rails.application.config.cloudflare.api_token}",
      "Content-Type"  => "application/json"
    }
  end

  # Create a custom hostname in Cloudflare for SaaS
  # Returns the parsed response body hash
  def create_custom_hostname(hostname)
    response = self.class.post(
      "/zones/#{@zone_id}/custom_hostnames",
      headers: @headers,
      body: {
        hostname: hostname,
        ssl: {
          method: "http",
          type: "dv",
          settings: {
            http2: "on",
            min_tls_version: "1.2"
          }
        }
      }.to_json
    )

    parsed = response.parsed_response
    raise Error, error_messages(parsed) unless parsed["success"]

    parsed["result"]
  end

  # Get the current status of a custom hostname
  def get_custom_hostname(cf_hostname_id)
    response = self.class.get(
      "/zones/#{@zone_id}/custom_hostnames/#{cf_hostname_id}",
      headers: @headers
    )

    parsed = response.parsed_response
    raise Error, error_messages(parsed) unless parsed["success"]

    parsed["result"]
  end

  # Delete a custom hostname from Cloudflare
  def delete_custom_hostname(cf_hostname_id)
    response = self.class.delete(
      "/zones/#{@zone_id}/custom_hostnames/#{cf_hostname_id}",
      headers: @headers
    )

    parsed = response.parsed_response
    raise Error, error_messages(parsed) unless parsed["success"]

    true
  end

  # Convenience: extract domain + SSL status from a CF result hash
  def self.extract_status(result)
    {
      domain_status: result["status"],
      ssl_status: result.dig("ssl", "status"),
      verification_token: result.dig("ssl", "validation_records", 0, "txt_name"),
      verification_errors: result["verification_errors"] || []
    }
  end

  # The CNAME target that customers should point their domain to
  def cname_target
    @cname_target
  end

  private

  def error_messages(parsed)
    errors = parsed["errors"] || []
    errors.map { |e| e["message"] }.join(", ").presence || "Unknown Cloudflare API error"
  end
end
