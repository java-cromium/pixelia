module Ecommerce
  class WoocommerceSyncJob < BaseSyncJob
    queue_as :default

    def perform(ecommerce_store_id)
      store = EcommerceStore.find(ecommerce_store_id)

      return unless store.platform == "WooCommerce"
      return unless store.api_key.present? && store.api_secret.present?

      log_sync(store, "Starting WooCommerce sync...")

      result = Ecommerce::WoocommerceSyncService.new(store).call

      if result[:success]
        log_sync(store, "Sync complete — #{result[:orders_count]} orders, #{result[:products_count]} products fetched.")
      else
        log_sync(store, "Sync failed — #{result[:error]}")
        raise StandardError, result[:error]
      end
    end
  end
end
