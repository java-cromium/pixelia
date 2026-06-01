class Portal::ChatsController < Portal::BaseController
  before_action :set_conversation, only: [:show, :message]

  def index
    @conversations = @account.chat_conversations
      .where(user: current_user)
      .active
      .recent
      .limit(20)
  end

  def show
    @messages = @conversation.chat_messages.chronological
  end

  def create
    @conversation = @account.chat_conversations.create!(
      user: current_user,
      title: params[:title].presence || "New conversation"
    )

    if params[:message].present?
      service = AiChatService.new(@conversation)
      service.send_message(params[:message])
    end

    redirect_to portal_chat_path(@conversation)
  end

  def message
    service = AiChatService.new(@conversation)
    service.send_message(params[:message])

    respond_to do |format|
      format.turbo_stream do
        @messages = @conversation.chat_messages.chronological
        render turbo_stream: turbo_stream.replace(
          "chat-messages",
          partial: "portal/chats/messages",
          locals: { messages: @messages }
        )
      end
      format.html { redirect_to portal_chat_path(@conversation) }
    end
  end

  def destroy
    conversation = @account.chat_conversations.find(params[:id])
    conversation.archive!
    redirect_to portal_chats_path, notice: "Conversation archived."
  end

  private

  def set_conversation
    @conversation = @account.chat_conversations
      .where(user: current_user)
      .find(params[:id])
  end
end
