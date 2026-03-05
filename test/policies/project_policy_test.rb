require "test_helper"

class ProjectPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @client_user = users(:client_user_one)
    @own_project = projects(:acme_website)
    @other_project = projects(:globex_store)
  end

  test "anyone can index projects" do
    assert ProjectPolicy.new(@admin, Project).index?
    assert ProjectPolicy.new(@client_user, Project).index?
  end

  test "super_admin can show any project" do
    assert ProjectPolicy.new(@admin, @own_project).show?
    assert ProjectPolicy.new(@admin, @other_project).show?
  end

  test "client_user can show own project" do
    assert ProjectPolicy.new(@client_user, @own_project).show?
  end

  test "client_user cannot show other client project" do
    refute ProjectPolicy.new(@client_user, @other_project).show?
  end

  test "super_admin can create projects" do
    assert ProjectPolicy.new(@admin, Project.new).create?
  end

  test "client_user cannot create projects" do
    refute ProjectPolicy.new(@client_user, Project.new).create?
  end

  test "super_admin can update projects" do
    assert ProjectPolicy.new(@admin, @own_project).update?
  end

  test "client_user cannot update projects" do
    refute ProjectPolicy.new(@client_user, @own_project).update?
  end

  test "super_admin can destroy projects" do
    assert ProjectPolicy.new(@admin, @own_project).destroy?
  end

  test "client_user cannot destroy projects" do
    refute ProjectPolicy.new(@client_user, @own_project).destroy?
  end

  test "scope returns all projects for super_admin" do
    scope = ProjectPolicy::Scope.new(@admin, Project).resolve
    assert_equal Project.count, scope.count
  end

  test "scope returns only own projects for client_user" do
    scope = ProjectPolicy::Scope.new(@client_user, Project).resolve
    scope.each do |project|
      assert_equal @client_user.client_id, project.client_id
    end
  end
end
