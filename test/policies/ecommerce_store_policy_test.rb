require "test_helper"

class EcommerceStorePolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @owner = users(:owner_one)
    @own_store = ecommerce_stores(:acme_shopify)
    @other_store = ecommerce_stores(:globex_woo)
  end

  test "anyone can index ecommerce stores" do
    assert EcommerceStorePolicy.new(@admin, EcommerceStore).index?
    assert EcommerceStorePolicy.new(@owner, EcommerceStore).index?
  end

  test "super_admin can show any store" do
    assert EcommerceStorePolicy.new(@admin, @own_store).show?
    assert EcommerceStorePolicy.new(@admin, @other_store).show?
  end

  test "client_user can show own store" do
    assert EcommerceStorePolicy.new(@owner, @own_store).show?
  end

  test "client_user cannot show other account store" do
    refute EcommerceStorePolicy.new(@owner, @other_store).show?
  end

  test "scope returns all stores for super_admin" do
    scope = EcommerceStorePolicy::Scope.new(@admin, EcommerceStore).resolve
    assert_equal EcommerceStore.count, scope.count
  end

  test "scope returns only own stores for client_user" do
    scope = EcommerceStorePolicy::Scope.new(@owner, EcommerceStore).resolve
    scope.each do |store|
      assert_equal @owner.account_id, store.account_id
    end
  end
end
