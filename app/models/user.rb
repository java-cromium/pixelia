class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :account, optional: true
  has_many :chat_conversations, dependent: :destroy

  enum :role, { super_admin: 0, owner: 1, member: 2 }

  # Virtual attribute for signup form
  attr_accessor :company_name

  validates :company_name, presence: true, on: :create, unless: -> { super_admin? || account.present? }

  after_create :provision_account!, unless: -> { super_admin? || account.present? }

  def onboarded?
    onboarding_completed_at.present?
  end

  private

  def provision_account!
    account = Account.create!(
      name: company_name.presence || email.split("@").first.titleize,
      status: "active",
      plan: "free",
      subscription_status: "trialing",
      trial_ends_at: 14.days.from_now
    )
    update!(account: account, role: :owner)
  end
end
