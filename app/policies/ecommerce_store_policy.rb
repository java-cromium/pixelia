# frozen_string_literal: true

class EcommerceStorePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.super_admin? || record.client_id == user.client_id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin?
        scope.all
      else
        scope.where(client_id: user.client_id)
      end
    end
  end
end
