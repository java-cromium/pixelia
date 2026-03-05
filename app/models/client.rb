class Client < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :projects, dependent: :destroy
end
