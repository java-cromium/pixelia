require "test_helper"

class ClientPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @client_user = users(:client_user_one)
    @own_client = clients(:acme)
    @other_client = clients(:globex)
  end

  test "super_admin can index clients" do
    assert ClientPolicy.new(@admin, Client).index?
  end

  test "client_user cannot index clients" do
    refute ClientPolicy.new(@client_user, Client).index?
  end

  test "super_admin can show any client" do
    assert ClientPolicy.new(@admin, @own_client).show?
    assert ClientPolicy.new(@admin, @other_client).show?
  end

  test "client_user can show own client" do
    assert ClientPolicy.new(@client_user, @own_client).show?
  end

  test "client_user cannot show other client" do
    refute ClientPolicy.new(@client_user, @other_client).show?
  end

  test "super_admin can create clients" do
    assert ClientPolicy.new(@admin, Client.new).create?
  end

  test "client_user cannot create clients" do
    refute ClientPolicy.new(@client_user, Client.new).create?
  end

  test "super_admin can update clients" do
    assert ClientPolicy.new(@admin, @own_client).update?
  end

  test "client_user cannot update clients" do
    refute ClientPolicy.new(@client_user, @own_client).update?
  end

  test "super_admin can destroy clients" do
    assert ClientPolicy.new(@admin, @own_client).destroy?
  end

  test "client_user cannot destroy clients" do
    refute ClientPolicy.new(@client_user, @own_client).destroy?
  end

  test "scope returns all clients for super_admin" do
    scope = ClientPolicy::Scope.new(@admin, Client).resolve
    assert_equal Client.count, scope.count
  end

  test "scope returns only own client for client_user" do
    scope = ClientPolicy::Scope.new(@client_user, Client).resolve
    assert_equal 1, scope.count
    assert_includes scope, @own_client
  end
end
