require "test_helper"

class EcommerceStorePolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @client_user = users(:client_user_one)
    @own_store = ecommerce_stores(:acme_shopify)
    @other_store = ecommerce_stores(:globex_woo)
  end

  test "anyone can index ecommerce stores" do
    assert EcommerceStorePolicy.new(@admin, EcommerceStore).index?
    assert EcommerceStorePolicy.new(@client_user, EcommerceStore).index?
  end

  test "super_admin can show any store" do
    assert EcommerceStorePolicy.new(@admin, @own_store).show?
    assert EcommerceStorePolicy.new(@admin, @other_store).show?
  end

  test "client_user can show own store" do
    assert EcommerceStorePolicy.new(@client_user, @own_store).show?
  end

  test "client_user cannot show other client store" do
    refute EcommerceStorePolicy.new(@client_user, @other_store).show?
  end

  test "scope returns all stores for super_admin" do
    scope = EcommerceStorePolicy::Scope.new(@admin, EcommerceStore).resolve
    assert_equal EcommerceStore.count, scope.count
  end

  test "scope returns only own stores for client_user" do
    scope = EcommerceStorePolicy::Scope.new(@client_user, EcommerceStore).resolve
    scope.each do |store|
      assert_equal @client_user.client_id, store.client_id
    end
  end
end
