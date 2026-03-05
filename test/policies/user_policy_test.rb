require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @client_user = users(:client_user_one)
    @other_user = users(:client_user_two)
  end

  test "super_admin can index users" do
    assert UserPolicy.new(@admin, User).index?
  end

  test "client_user cannot index users" do
    refute UserPolicy.new(@client_user, User).index?
  end

  test "super_admin can show any user" do
    assert UserPolicy.new(@admin, @client_user).show?
  end

  test "client_user can show self" do
    assert UserPolicy.new(@client_user, @client_user).show?
  end

  test "client_user cannot show other user" do
    refute UserPolicy.new(@client_user, @other_user).show?
  end

  test "super_admin can create users" do
    assert UserPolicy.new(@admin, User.new).create?
  end

  test "client_user cannot create users" do
    refute UserPolicy.new(@client_user, User.new).create?
  end

  test "super_admin can update any user" do
    assert UserPolicy.new(@admin, @client_user).update?
  end

  test "client_user can update self" do
    assert UserPolicy.new(@client_user, @client_user).update?
  end

  test "client_user cannot update other user" do
    refute UserPolicy.new(@client_user, @other_user).update?
  end

  test "super_admin can destroy other user" do
    assert UserPolicy.new(@admin, @client_user).destroy?
  end

  test "super_admin cannot destroy self" do
    refute UserPolicy.new(@admin, @admin).destroy?
  end

  test "client_user cannot destroy any user" do
    refute UserPolicy.new(@client_user, @client_user).destroy?
    refute UserPolicy.new(@client_user, @other_user).destroy?
  end

  test "scope returns all users for super_admin" do
    scope = UserPolicy::Scope.new(@admin, User).resolve
    assert_equal User.count, scope.count
  end

  test "scope returns only self for client_user" do
    scope = UserPolicy::Scope.new(@client_user, User).resolve
    assert_equal 1, scope.count
    assert_includes scope, @client_user
  end
end
