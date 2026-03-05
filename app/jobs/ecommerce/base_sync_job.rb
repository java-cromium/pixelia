module Ecommerce
  class BaseSyncJob < ApplicationJob
    queue_as :default

    retry_on StandardError, wait: :polynomially_longer, attempts: 5

    discard_on ActiveRecord::RecordNotFound

    private

    def log_sync(store, message)
      Rails.logger.info("[EcommerceSync][#{store.platform}][Store##{store.id}] #{message}")
    end
  end
end
