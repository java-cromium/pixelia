module Ecommerce
  class ShopifySyncService
    include HTTParty

    SHOPIFY_API_VERSION = "2024-10"

    attr_reader :store

    def initialize(store)
      @store = store
      @base_url = "#{store.store_url}/admin/api/#{SHOPIFY_API_VERSION}"
    end

    def call
      orders   = fetch_orders
      products = fetch_products

      {
        success: true,
        orders_count: orders.size,
        products_count: products.size,
        orders: orders,
        products: products
      }
    rescue StandardError => e
      { success: false, error: e.message }
    end

    private

    def fetch_orders
      Rails.logger.info("[ShopifySyncService] Fetching orders from #{store.store_url}...")

      response = self.class.get(
        "#{@base_url}/orders.json",
        query: { status: "any", limit: 50 },
        headers: auth_headers,
        timeout: 30
      )

      handle_response(response, "orders")
    end

    def fetch_products
      Rails.logger.info("[ShopifySyncService] Fetching products from #{store.store_url}...")

      response = self.class.get(
        "#{@base_url}/products.json",
        query: { limit: 50 },
        headers: auth_headers,
        timeout: 30
      )

      handle_response(response, "products")
    end

    def auth_headers
      { "X-Shopify-Access-Token" => store.api_key }
    end

    def handle_response(response, resource_key)
      if response.success?
        parsed = response.parsed_response
        parsed[resource_key] || []
      else
        Rails.logger.error("[ShopifySyncService] HTTP #{response.code}: #{response.message}")
        raise "Shopify API error #{response.code}: #{response.message}"
      end
    end
  end
end
