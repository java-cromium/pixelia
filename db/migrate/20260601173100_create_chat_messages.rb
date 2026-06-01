class CreateChatMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :chat_messages do |t|
      t.references :chat_conversation, null: false, foreign_key: true
      t.string :role, null: false
      t.text :content, null: false
      t.integer :tokens_used

      t.timestamps
    end
  end
end
