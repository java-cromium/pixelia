# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    user.super_admin?
  end

  def show?
    user.super_admin? || record == user
  end

  def create?
    user.super_admin?
  end

  def update?
    user.super_admin? || record == user
  end

  def destroy?
    user.super_admin? && record != user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end
end
