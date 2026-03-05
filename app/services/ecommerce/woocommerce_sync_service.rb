module Ecommerce
  class WoocommerceSyncService
    include HTTParty

    BASE_API_PATH = "/wp-json/wc/v3"

    attr_reader :store

    def initialize(store)
      @store = store
      @base_url = "#{store.store_url}#{BASE_API_PATH}"
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
      Rails.logger.info("[WoocommerceSyncService] Fetching orders from #{store.store_url}...")

      response = self.class.get(
        "#{@base_url}/orders",
        query: { per_page: 50 },
        basic_auth: auth,
        timeout: 30
      )

      handle_response(response)
    end

    def fetch_products
      Rails.logger.info("[WoocommerceSyncService] Fetching products from #{store.store_url}...")

      response = self.class.get(
        "#{@base_url}/products",
        query: { per_page: 50 },
        basic_auth: auth,
        timeout: 30
      )

      handle_response(response)
    end

    def auth
      { username: store.api_key, password: store.api_secret }
    end

    def handle_response(response)
      if response.success?
        response.parsed_response || []
      else
        Rails.logger.error("[WoocommerceSyncService] HTTP #{response.code}: #{response.message}")
        raise "WooCommerce API error #{response.code}: #{response.message}"
      end
    end
  end
end
