require "test_helper"

class LeadPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @client_user = users(:client_user_one)
    @lead = leads(:new_lead)
  end

  test "super_admin can index leads" do
    assert LeadPolicy.new(@admin, Lead).index?
  end

  test "client_user cannot index leads" do
    refute LeadPolicy.new(@client_user, Lead).index?
  end

  test "super_admin can show leads" do
    assert LeadPolicy.new(@admin, @lead).show?
  end

  test "client_user cannot show leads" do
    refute LeadPolicy.new(@client_user, @lead).show?
  end

  test "anyone can create leads" do
    assert LeadPolicy.new(@admin, Lead.new).create?
    assert LeadPolicy.new(@client_user, Lead.new).create?
  end

  test "super_admin can update leads" do
    assert LeadPolicy.new(@admin, @lead).update?
  end

  test "client_user cannot update leads" do
    refute LeadPolicy.new(@client_user, @lead).update?
  end

  test "super_admin can destroy leads" do
    assert LeadPolicy.new(@admin, @lead).destroy?
  end

  test "client_user cannot destroy leads" do
    refute LeadPolicy.new(@client_user, @lead).destroy?
  end

  test "scope returns all leads for super_admin" do
    scope = LeadPolicy::Scope.new(@admin, Lead).resolve
    assert_equal Lead.count, scope.count
  end

  test "scope returns none for client_user" do
    scope = LeadPolicy::Scope.new(@client_user, Lead).resolve
    assert_equal 0, scope.count
  end
end
