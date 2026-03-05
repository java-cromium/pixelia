class Project < ApplicationRecord
  belongs_to :client
  has_many :ecommerce_stores, dependent: :destroy

  acts_as_tenant(:client)
end
