class AiChatService
  MODEL = "gpt-4o-mini"
  MAX_CONTEXT_MESSAGES = 20

  def initialize(conversation)
    @conversation = conversation
    @account = conversation.account
    @client = OpenAI::Client.new
  end

  def send_message(user_content)
    @conversation.chat_messages.create!(role: "user", content: user_content)

    messages = build_messages
    response = @client.chat(parameters: {
      model: MODEL,
      messages: messages,
      temperature: 0.7,
      max_tokens: 1024
    })

    assistant_content = response.dig("choices", 0, "message", "content")
    tokens = response.dig("usage", "total_tokens")

    @conversation.chat_messages.create!(
      role: "assistant",
      content: assistant_content,
      tokens_used: tokens
    )
  end

  def send_message_streaming(user_content, &block)
    @conversation.chat_messages.create!(role: "user", content: user_content)

    messages = build_messages
    full_response = +""

    @client.chat(parameters: {
      model: MODEL,
      messages: messages,
      temperature: 0.7,
      max_tokens: 1024,
      stream: proc { |chunk, _bytesize|
        delta = chunk.dig("choices", 0, "delta", "content")
        if delta
          full_response << delta
          block.call(delta) if block
        end
      }
    })

    @conversation.chat_messages.create!(
      role: "assistant",
      content: full_response
    )
  end

  private

  def build_messages
    [system_message] + context_messages
  end

  def system_message
    {
      role: "system",
      content: system_prompt
    }
  end

  def context_messages
    @conversation.chat_messages
      .chronological
      .last(MAX_CONTEXT_MESSAGES)
      .map { |m| { role: m.role, content: m.content } }
  end

  def system_prompt
    <<~PROMPT
      You are Pixelia AI, a helpful assistant for the Pixelia platform — a SaaS tool for managing websites, e-commerce stores, Google Ads campaigns, and Meta Ads campaigns.

      Current user context:
      - Account: #{@account.name}
      - Plan: #{@account.plan} (#{@account.subscription_status})
      - Sites: #{@account.sites.count}
      - Stores: #{@account.ecommerce_stores.count}
      - Google Ads: #{@account.google_ad_account&.connected? ? "Connected" : "Not connected"}
      - Meta Ads: #{@account.meta_ad_account&.connected? ? "Connected" : "Not connected"}

      You can help with:
      - Explaining platform features (sites, stores, campaigns, billing)
      - Guiding users through setting up Google Ads or Meta Ads campaigns
      - Answering questions about plans, billing, and subscriptions
      - Providing best practices for ad campaigns (targeting, budgets, objectives)
      - Troubleshooting common issues (domain setup, OAuth connections)
      - General digital marketing advice

      Guidelines:
      - Be concise and helpful. Use short paragraphs.
      - If you don't know something specific to their account data, say so.
      - Never share or ask for passwords, API keys, or sensitive credentials.
      - Format responses with markdown when helpful (bold, lists, headers).
      - If asked about something outside the platform scope, politely redirect.
    PROMPT
  end
end
