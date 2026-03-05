require "test_helper"

class EcommerceStoreTest < ActiveSupport::TestCase
  setup do
    @store = ecommerce_stores(:acme_shopify)
  end

  test "validates platform presence" do
    @store.platform = nil
    refute @store.valid?
    assert_includes @store.errors[:platform], "can't be blank"
  end

  test "validates platform inclusion" do
    @store.platform = "magento"
    refute @store.valid?
    assert_includes @store.errors[:platform], "is not included in the list"
  end

  test "validates store_url presence" do
    @store.store_url = nil
    refute @store.valid?
    assert_includes @store.errors[:store_url], "can't be blank"
  end

  test "connected? returns true when keys present" do
    store = EcommerceStore.new(
      project: projects(:acme_website),
      client: clients(:acme),
      platform: "shopify",
      store_url: "https://test.myshopify.com",
      api_key: "test_key_123",
      api_secret: "test_secret_456"
    )
    assert store.connected?
  end

  test "connected? returns false when keys missing" do
    store = EcommerceStore.new(
      project: projects(:acme_website),
      client: clients(:acme),
      platform: "shopify",
      store_url: "https://test.myshopify.com",
      api_key: nil,
      api_secret: nil
    )
    refute store.connected?
  end

  test "masked_api_key masks the key" do
    store = EcommerceStore.new(api_key: "abcd1234567890")
    masked = store.masked_api_key
    assert masked.start_with?("abcd")
    assert masked.include?("•")
  end

  test "masked_api_key returns Not set when blank" do
    store = EcommerceStore.new(api_key: nil)
    assert_equal "Not set", store.masked_api_key
  end
end
