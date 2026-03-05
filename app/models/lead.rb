class Lead < ApplicationRecord
  validates :first_name, presence: true
  validates :email, presence: true
  validates :project_type, presence: true
end
