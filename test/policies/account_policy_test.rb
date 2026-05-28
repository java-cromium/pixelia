require "test_helper"

class AccountPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @owner = users(:owner_one)
    @own_account = accounts(:acme)
    @other_account = accounts(:globex)
  end

  test "super_admin can index accounts" do
    assert AccountPolicy.new(@admin, Account).index?
  end

  test "owner cannot index accounts" do
    refute AccountPolicy.new(@owner, Account).index?
  end

  test "super_admin can show any account" do
    assert AccountPolicy.new(@admin, @own_account).show?
    assert AccountPolicy.new(@admin, @other_account).show?
  end

  test "owner can show own account" do
    assert AccountPolicy.new(@owner, @own_account).show?
  end

  test "owner cannot show other account" do
    refute AccountPolicy.new(@owner, @other_account).show?
  end

  test "super_admin can create accounts" do
    assert AccountPolicy.new(@admin, Account.new).create?
  end

  test "owner cannot create accounts" do
    refute AccountPolicy.new(@owner, Account.new).create?
  end

  test "super_admin can update accounts" do
    assert AccountPolicy.new(@admin, @own_account).update?
  end

  test "owner cannot update accounts" do
    refute AccountPolicy.new(@owner, @own_account).update?
  end

  test "super_admin can destroy accounts" do
    assert AccountPolicy.new(@admin, @own_account).destroy?
  end

  test "owner cannot destroy accounts" do
    refute AccountPolicy.new(@owner, @own_account).destroy?
  end

  test "scope returns all accounts for super_admin" do
    scope = AccountPolicy::Scope.new(@admin, Account).resolve
    assert_equal Account.count, scope.count
  end

  test "scope returns only own account for owner" do
    scope = AccountPolicy::Scope.new(@owner, Account).resolve
    assert_equal 1, scope.count
    assert_includes scope, @own_account
  end
end
