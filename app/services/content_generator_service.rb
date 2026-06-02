class ContentGeneratorService
  MODELS = {
    "openai" => "gpt-4o-mini",
    "gemini" => "gemini-2.0-flash",
    "claude" => "claude-sonnet-4-20250514"
  }.freeze

  class GenerationError < StandardError; end

  def initialize(account)
    @account = account
    @provider = account.ai_provider
    @api_key = account.ai_api_key
  end

  # Generate content for a specific section of the website
  # section: :tagline, :value_proposition, :services, :about, :faqs
  def generate(section:, business_name:, industry: nil, context: {})
    prompt = build_prompt(section, business_name, industry, context)

    case @provider
    when "openai"  then call_openai(prompt)
    when "gemini"  then call_gemini(prompt)
    when "claude"  then call_claude(prompt)
    else
      raise GenerationError, "Unknown AI provider: #{@provider}"
    end
  rescue => e
    raise GenerationError, "AI generation failed: #{e.message}"
  end

  private

  def build_prompt(section, business_name, industry, context)
    industry_text = industry.present? ? " in the #{industry} industry" : ""

    case section
    when :tagline
      <<~PROMPT
        Generate a short, compelling tagline (max 10 words) for a business called "#{business_name}"#{industry_text}.
        Return ONLY the tagline text, no quotes, no explanation.
      PROMPT
    when :value_proposition
      <<~PROMPT
        Write a 1-2 sentence value proposition for "#{business_name}"#{industry_text}.
        It should explain what the business does and why customers should choose them.
        Return ONLY the text, no quotes, no explanation.
      PROMPT
    when :services
      existing = context[:existing_services]
      count = context[:count] || 4
      existing_text = existing.present? ? "\nExisting services (enhance or add more): #{existing}" : ""
      <<~PROMPT
        Generate exactly #{count} services for "#{business_name}"#{industry_text}.#{existing_text}
        Return as a JSON array of objects with "name" and "description" keys.
        Each description should be 1-2 sentences.
        Return ONLY valid JSON, no markdown code fences, no explanation.
        Example: [{"name": "Service Name", "description": "Brief description."}]
      PROMPT
    when :about
      <<~PROMPT
        Write a compelling "About Us" paragraph (3-5 sentences) for "#{business_name}"#{industry_text}.
        Focus on the company's mission, expertise, and commitment to customers.
        Return ONLY the paragraph text, no quotes, no heading.
      PROMPT
    when :faqs
      services_text = context[:services].present? ? "\nTheir services include: #{context[:services]}" : ""
      count = context[:count] || 4
      <<~PROMPT
        Generate exactly #{count} frequently asked questions and answers for "#{business_name}"#{industry_text}.#{services_text}
        Return as a JSON array of objects with "question" and "answer" keys.
        Each answer should be 1-3 sentences.
        Return ONLY valid JSON, no markdown code fences, no explanation.
        Example: [{"question": "What services do you offer?", "answer": "We offer..."}]
      PROMPT
    when :team_info
      <<~PROMPT
        Write a brief team description (2-3 sentences) for "#{business_name}"#{industry_text}.
        Highlight the team's collective expertise and passion.
        Return ONLY the text, no quotes, no heading.
      PROMPT
    else
      raise GenerationError, "Unknown section: #{section}"
    end
  end

  # ─── OPENAI ─────────────────────────────────────────────────────

  def call_openai(prompt)
    client = OpenAI::Client.new(access_token: @api_key)
    response = client.chat(parameters: {
      model: MODELS["openai"],
      messages: [
        { role: "system", content: "You are a professional copywriter for business websites. Generate concise, high-quality content." },
        { role: "user", content: prompt }
      ],
      temperature: 0.7,
      max_tokens: 1024
    })

    content = response.dig("choices", 0, "message", "content")
    raise GenerationError, "No content returned from OpenAI" if content.blank?
    content.strip
  end

  # ─── GOOGLE GEMINI ──────────────────────────────────────────────

  def call_gemini(prompt)
    url = "https://generativelanguage.googleapis.com/v1beta/models/#{MODELS['gemini']}:generateContent?key=#{@api_key}"

    body = {
      contents: [{ parts: [{ text: "You are a professional copywriter for business websites. Generate concise, high-quality content.\n\n#{prompt}" }] }],
      generationConfig: { temperature: 0.7, maxOutputTokens: 1024 }
    }

    response = HTTParty.post(url, body: body.to_json, headers: { "Content-Type" => "application/json" })

    if response.success?
      content = response.dig("candidates", 0, "content", "parts", 0, "text")
      raise GenerationError, "No content returned from Gemini" if content.blank?
      content.strip
    else
      error = response.dig("error", "message") || response.body
      raise GenerationError, "Gemini API error: #{error}"
    end
  end

  # ─── ANTHROPIC CLAUDE ───────────────────────────────────────────

  def call_claude(prompt)
    url = "https://api.anthropic.com/v1/messages"

    body = {
      model: MODELS["claude"],
      max_tokens: 1024,
      system: "You are a professional copywriter for business websites. Generate concise, high-quality content.",
      messages: [{ role: "user", content: prompt }]
    }

    response = HTTParty.post(url,
      body: body.to_json,
      headers: {
        "Content-Type" => "application/json",
        "x-api-key" => @api_key,
        "anthropic-version" => "2023-06-01"
      }
    )

    if response.success?
      content = response.dig("content", 0, "text")
      raise GenerationError, "No content returned from Claude" if content.blank?
      content.strip
    else
      error = response.dig("error", "message") || response.body
      raise GenerationError, "Claude API error: #{error}"
    end
  end
end
