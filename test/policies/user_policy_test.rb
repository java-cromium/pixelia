require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @owner = users(:owner_one)
    @other_user = users(:owner_two)
  end

  test "super_admin can index users" do
    assert UserPolicy.new(@admin, User).index?
  end

  test "owner cannot index users" do
    refute UserPolicy.new(@owner, User).index?
  end

  test "super_admin can show any user" do
    assert UserPolicy.new(@admin, @owner).show?
  end

  test "owner can show self" do
    assert UserPolicy.new(@owner, @owner).show?
  end

  test "owner cannot show other user" do
    refute UserPolicy.new(@owner, @other_user).show?
  end

  test "super_admin can create users" do
    assert UserPolicy.new(@admin, User.new).create?
  end

  test "owner cannot create users" do
    refute UserPolicy.new(@owner, User.new).create?
  end

  test "super_admin can update any user" do
    assert UserPolicy.new(@admin, @owner).update?
  end

  test "owner can update self" do
    assert UserPolicy.new(@owner, @owner).update?
  end

  test "owner cannot update other user" do
    refute UserPolicy.new(@owner, @other_user).update?
  end

  test "super_admin can destroy other user" do
    assert UserPolicy.new(@admin, @owner).destroy?
  end

  test "super_admin cannot destroy self" do
    refute UserPolicy.new(@admin, @admin).destroy?
  end

  test "owner cannot destroy any user" do
    refute UserPolicy.new(@owner, @owner).destroy?
    refute UserPolicy.new(@owner, @other_user).destroy?
  end

  test "scope returns all users for super_admin" do
    scope = UserPolicy::Scope.new(@admin, User).resolve
    assert_equal User.count, scope.count
  end

  test "scope returns only self for owner" do
    scope = UserPolicy::Scope.new(@owner, User).resolve
    assert_equal 1, scope.count
    assert_includes scope, @owner
  end
end
