class ChatMessage < ApplicationRecord
  belongs_to :chat_conversation, touch: true

  ROLES = %w[user assistant system].freeze

  validates :role, inclusion: { in: ROLES }
  validates :content, presence: true

  scope :chronological, -> { order(:created_at) }

  def user?
    role == "user"
  end

  def assistant?
    role == "assistant"
  end

  def system?
    role == "system"
  end
end
