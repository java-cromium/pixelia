class CreateChatConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :chat_conversations do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, default: "New conversation"
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :chat_conversations, [:account_id, :updated_at]
  end
end
