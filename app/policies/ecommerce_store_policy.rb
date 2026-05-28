# frozen_string_literal: true

class EcommerceStorePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.super_admin? || record.account_id == user.account_id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin?
        scope.all
      else
        scope.where(account_id: user.account_id)
      end
    end
  end
end
