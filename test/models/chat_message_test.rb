require "test_helper"

class ChatMessageTest < ActiveSupport::TestCase
  setup do
    @user_msg = chat_messages(:user_msg)
    @assistant_msg = chat_messages(:assistant_msg)
  end

  test "belongs to chat_conversation" do
    assert_equal chat_conversations(:active_chat), @user_msg.chat_conversation
  end

  test "validates role inclusion" do
    @user_msg.role = "invalid"
    assert_not @user_msg.valid?
  end

  test "valid roles" do
    %w[user assistant system].each do |r|
      @user_msg.role = r
      assert @user_msg.valid?, "Expected role '#{r}' to be valid"
    end
  end

  test "validates content presence" do
    @user_msg.content = ""
    assert_not @user_msg.valid?
  end

  test "user? returns true for user role" do
    assert @user_msg.user?
    assert_not @user_msg.assistant?
  end

  test "assistant? returns true for assistant role" do
    assert @assistant_msg.assistant?
    assert_not @assistant_msg.user?
  end

  test "system? returns true for system role" do
    msg = ChatMessage.new(role: "system", content: "test")
    assert msg.system?
  end

  test "chronological scope orders by created_at" do
    msgs = ChatMessage.chronological
    assert msgs.first.created_at <= msgs.last.created_at
  end

  test "touch updates conversation updated_at" do
    conversation = @user_msg.chat_conversation
    old_time = conversation.updated_at
    travel 1.minute do
      @user_msg.update!(content: "Updated content")
      assert conversation.reload.updated_at > old_time
    end
  end
end
