module Ecommerce
  class SyncAllStoresJob < ApplicationJob
    queue_as :low

    def perform
      Rails.logger.info("[EcommerceSync] Dispatching sync for all active stores...")

      ActsAsTenant.without_tenant do
        EcommerceStore.find_each do |store|
          case store.platform
          when "Shopify"
            Ecommerce::ShopifySyncJob.perform_later(store.id)
          when "WooCommerce"
            Ecommerce::WoocommerceSyncJob.perform_later(store.id)
          else
            Rails.logger.warn("[EcommerceSync] Unknown platform '#{store.platform}' for Store##{store.id}")
          end
        end
      end
    end
  end
end
