require "test_helper"

class ChatConversationTest < ActiveSupport::TestCase
  setup do
    @conversation = chat_conversations(:active_chat)
    @archived = chat_conversations(:archived_chat)
  end

  test "belongs to account" do
    assert_equal accounts(:acme), @conversation.account
  end

  test "belongs to user" do
    assert_equal users(:owner_one), @conversation.user
  end

  test "has many chat_messages" do
    assert_respond_to @conversation, :chat_messages
    assert @conversation.chat_messages.count >= 1
  end

  test "validates status inclusion" do
    @conversation.status = "invalid"
    assert_not @conversation.valid?
  end

  test "valid statuses" do
    %w[active archived].each do |s|
      @conversation.status = s
      assert @conversation.valid?, "Expected '#{s}' to be valid"
    end
  end

  test "active scope excludes archived" do
    results = ChatConversation.active
    assert_includes results, @conversation
    assert_not_includes results, @archived
  end

  test "recent scope orders by updated_at desc" do
    results = ChatConversation.recent
    assert_equal results.first.updated_at, results.maximum(:updated_at)
  end

  test "active? returns true for active status" do
    assert @conversation.active?
  end

  test "active? returns false for archived status" do
    assert_not @archived.active?
  end

  test "archive! changes status to archived" do
    @conversation.archive!
    assert_equal "archived", @conversation.reload.status
  end

  test "messages_for_api returns role/content hashes" do
    msgs = @conversation.messages_for_api
    assert msgs.is_a?(Array)
    assert msgs.first.key?(:role)
    assert msgs.first.key?(:content)
  end
end
