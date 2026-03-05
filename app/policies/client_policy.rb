# frozen_string_literal: true

class ClientPolicy < ApplicationPolicy
  def index?
    user.super_admin?
  end

  def show?
    user.super_admin? || (user.client_user? && record == user.client)
  end

  def create?
    user.super_admin?
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
        scope.where(id: user.client_id)
      end
    end
  end
end
