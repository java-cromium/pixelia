# frozen_string_literal: true

class LeadPolicy < ApplicationPolicy
  def index?
    user.super_admin?
  end

  def show?
    user.super_admin?
  end

  def create?
    true
  end

  def update?
    user.super_admin?
  end

  def destroy?
    user.super_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
