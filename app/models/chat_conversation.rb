class ChatConversation < ApplicationRecord
  belongs_to :account
  belongs_to :user
  has_many :chat_messages, dependent: :destroy

  STATUSES = %w[active archived].freeze

  validates :status, inclusion: { in: STATUSES }

  scope :active, -> { where(status: "active") }
  scope :recent, -> { order(updated_at: :desc) }

  def active?
    status == "active"
  end

  def archive!
    update!(status: "archived")
  end

  def messages_for_api
    chat_messages.order(:created_at).map do |msg|
      { role: msg.role, content: msg.content }
    end
  end
end
