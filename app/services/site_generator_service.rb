require "net/http"

class SiteGeneratorService
  include Rails.application.routes.url_helpers

  PALETTES = [
    # ─── DARK BACKGROUNDS ───────────────────────────────────────────
    # Indigo / Cyan
    { primary: "#6366f1", accent: "#06b6d4", bg: "#0f172a", card: "#1e293b", text: "#f8fafc", muted: "#94a3b8", border: "#334155", name: "Midnight Indigo" },
    # Orange / Yellow
    { primary: "#f97316", accent: "#eab308", bg: "#1c1917", card: "#292524", text: "#fafaf9", muted: "#a8a29e", border: "#44403c", name: "Ember Gold" },
    # Pink / Purple
    { primary: "#ec4899", accent: "#8b5cf6", bg: "#0f0518", card: "#1a0a2e", text: "#faf5ff", muted: "#a78bfa", border: "#3b0764", name: "Neon Blossom" },
    # Emerald / Cyan
    { primary: "#10b981", accent: "#06b6d4", bg: "#022c22", card: "#064e3b", text: "#ecfdf5", muted: "#6ee7b7", border: "#065f46", name: "Forest Teal" },
    # Blue / Purple
    { primary: "#3b82f6", accent: "#8b5cf6", bg: "#0f172a", card: "#1e293b", text: "#f8fafc", muted: "#93c5fd", border: "#1e3a5f", name: "Electric Violet" },
    # Rose / Orange
    { primary: "#f43f5e", accent: "#fb923c", bg: "#1a0005", card: "#2d0a0a", text: "#fff1f2", muted: "#fda4af", border: "#4c0519", name: "Cherry Blaze" },
    # Teal / Lime
    { primary: "#14b8a6", accent: "#a3e635", bg: "#042f2e", card: "#134e4a", text: "#f0fdfa", muted: "#5eead4", border: "#115e59", name: "Tropical Mint" },
    # Amber / Red
    { primary: "#f59e0b", accent: "#ef4444", bg: "#1c1917", card: "#292524", text: "#fffbeb", muted: "#fcd34d", border: "#44403c", name: "Golden Flame" },
    # Violet / Rose
    { primary: "#8b5cf6", accent: "#f43f5e", bg: "#0c0a1d", card: "#1c1836", text: "#f5f3ff", muted: "#c4b5fd", border: "#2e1065", name: "Royal Magenta" },
    # Sky / Emerald
    { primary: "#0ea5e9", accent: "#10b981", bg: "#0c1929", card: "#172b45", text: "#f0f9ff", muted: "#7dd3fc", border: "#0c4a6e", name: "Ocean Breeze" },
    # Lime / Yellow
    { primary: "#84cc16", accent: "#facc15", bg: "#1a2e05", card: "#2d4a0e", text: "#f7fee7", muted: "#bef264", border: "#365314", name: "Acid Green" },
    # Fuchsia / Cyan
    { primary: "#d946ef", accent: "#22d3ee", bg: "#1a0527", card: "#2e0a40", text: "#fdf4ff", muted: "#e879f9", border: "#4a044e", name: "Cyber Punk" },
    # Red / Amber
    { primary: "#ef4444", accent: "#f59e0b", bg: "#1c0404", card: "#2d0808", text: "#fef2f2", muted: "#fca5a5", border: "#450a0a", name: "Crimson Sun" },
    # Slate / Indigo
    { primary: "#6366f1", accent: "#a5b4fc", bg: "#020617", card: "#0f172a", text: "#f1f5f9", muted: "#94a3b8", border: "#1e293b", name: "Deep Space" },
    # Cyan / Pink
    { primary: "#06b6d4", accent: "#f472b6", bg: "#083344", card: "#0e4f5e", text: "#ecfeff", muted: "#67e8f9", border: "#155e75", name: "Aqua Coral" },
    # Green / Orange
    { primary: "#22c55e", accent: "#f97316", bg: "#052e16", card: "#0b4d29", text: "#f0fdf4", muted: "#86efac", border: "#166534", name: "Jungle Fire" },
    # Purple / Teal
    { primary: "#a855f7", accent: "#2dd4bf", bg: "#0f051d", card: "#1c0e35", text: "#faf5ff", muted: "#c084fc", border: "#3b0764", name: "Mystic Aurora" },
    # Blue / Lime
    { primary: "#2563eb", accent: "#a3e635", bg: "#0a1628", card: "#152442", text: "#eff6ff", muted: "#93c5fd", border: "#1e3a5f", name: "Arctic Neon" },
    # Rose / Violet
    { primary: "#fb7185", accent: "#a78bfa", bg: "#1c0812", card: "#2d1020", text: "#fff1f2", muted: "#fda4af", border: "#4c0519", name: "Blush Plum" },
    # Amber / Emerald
    { primary: "#fbbf24", accent: "#34d399", bg: "#1c1a05", card: "#2d2b0e", text: "#fffbeb", muted: "#fde68a", border: "#422006", name: "Solar Garden" },
    # Indigo / Orange
    { primary: "#4f46e5", accent: "#fb923c", bg: "#0f0e2a", card: "#1e1c42", text: "#eef2ff", muted: "#a5b4fc", border: "#312e81", name: "Dusk Ember" },
    # Teal / Purple
    { primary: "#0d9488", accent: "#a855f7", bg: "#042f2e", card: "#0a4744", text: "#f0fdfa", muted: "#5eead4", border: "#115e59", name: "Jade Amethyst" },
    # Sky / Rose
    { primary: "#38bdf8", accent: "#fb7185", bg: "#0c1929", card: "#152d47", text: "#f0f9ff", muted: "#7dd3fc", border: "#0c4a6e", name: "Frost Rose" },
    # Lime / Fuchsia
    { primary: "#a3e635", accent: "#e879f9", bg: "#1a2e05", card: "#2a4a0d", text: "#f7fee7", muted: "#d9f99d", border: "#3f6212", name: "Electric Garden" },
    # Warm Neutral
    { primary: "#d97706", accent: "#b45309", bg: "#1c1917", card: "#292524", text: "#fef3c7", muted: "#d6d3d1", border: "#44403c", name: "Warm Earth" },

    # ─── LIGHT BACKGROUNDS ──────────────────────────────────────────
    # Blue / White
    { primary: "#2563eb", accent: "#0891b2", bg: "#ffffff", card: "#f8fafc", text: "#0f172a", muted: "#64748b", border: "#e2e8f0", name: "Clean Blue" },
    # Indigo / Light
    { primary: "#4f46e5", accent: "#7c3aed", bg: "#fafafa", card: "#ffffff", text: "#1e1b4b", muted: "#6b7280", border: "#e5e7eb", name: "Soft Indigo" },
    # Emerald / Light
    { primary: "#059669", accent: "#0d9488", bg: "#ffffff", card: "#f0fdf4", text: "#064e3b", muted: "#6b7280", border: "#d1fae5", name: "Fresh Mint" },
    # Rose / Light
    { primary: "#e11d48", accent: "#be185d", bg: "#fffbfb", card: "#fff1f2", text: "#1c1917", muted: "#6b7280", border: "#fecdd3", name: "Warm Rose" },
    # Orange / Light
    { primary: "#ea580c", accent: "#dc2626", bg: "#fffaf5", card: "#fff7ed", text: "#1c1917", muted: "#6b7280", border: "#fed7aa", name: "Sunset Cream" },
    # Purple / Light
    { primary: "#7c3aed", accent: "#db2777", bg: "#faf5ff", card: "#ffffff", text: "#1e1b4b", muted: "#6b7280", border: "#e9d5ff", name: "Lavender Dream" },
    # Teal / Light
    { primary: "#0f766e", accent: "#065f46", bg: "#f0fdfa", card: "#ffffff", text: "#042f2e", muted: "#6b7280", border: "#ccfbf1", name: "Sea Glass" },
    # Slate / Light
    { primary: "#334155", accent: "#6366f1", bg: "#ffffff", card: "#f8fafc", text: "#0f172a", muted: "#64748b", border: "#e2e8f0", name: "Modern Slate" },
    # Amber / Light
    { primary: "#b45309", accent: "#92400e", bg: "#fffbeb", card: "#ffffff", text: "#1c1917", muted: "#78716c", border: "#fde68a", name: "Honey Glow" },
    # Sky / Light
    { primary: "#0284c7", accent: "#0369a1", bg: "#f0f9ff", card: "#ffffff", text: "#0c4a6e", muted: "#64748b", border: "#bae6fd", name: "Clear Sky" },
    # Coral / Light
    { primary: "#f43f5e", accent: "#f97316", bg: "#ffffff", card: "#fff5f5", text: "#1c1917", muted: "#6b7280", border: "#fecaca", name: "Living Coral" },
    # Forest / Light
    { primary: "#15803d", accent: "#4d7c0f", bg: "#f7fee7", card: "#ffffff", text: "#14532d", muted: "#6b7280", border: "#bbf7d0", name: "Garden Path" },
    # Navy / Light
    { primary: "#1e40af", accent: "#1d4ed8", bg: "#ffffff", card: "#eff6ff", text: "#172554", muted: "#64748b", border: "#bfdbfe", name: "Navy Crisp" },
    # Plum / Light
    { primary: "#7e22ce", accent: "#a21caf", bg: "#fdf4ff", card: "#ffffff", text: "#3b0764", muted: "#6b7280", border: "#f0abfc", name: "Plum Blossom" },
    # Rust / Light
    { primary: "#c2410c", accent: "#9a3412", bg: "#fff7ed", card: "#ffffff", text: "#431407", muted: "#78716c", border: "#fdba74", name: "Terracotta" },
    # Sage / Light
    { primary: "#4d7c0f", accent: "#15803d", bg: "#f7fee7", card: "#ffffff", text: "#1a2e05", muted: "#6b7280", border: "#d9f99d", name: "Sage Meadow" },
    # Charcoal / Light
    { primary: "#18181b", accent: "#3f3f46", bg: "#fafafa", card: "#ffffff", text: "#18181b", muted: "#71717a", border: "#e4e4e7", name: "Monochrome" },
    # Cyan / Light
    { primary: "#0891b2", accent: "#0e7490", bg: "#ecfeff", card: "#ffffff", text: "#164e63", muted: "#64748b", border: "#a5f3fc", name: "Aqua Fresh" },
    # Wine / Light
    { primary: "#9f1239", accent: "#be123c", bg: "#fff1f2", card: "#ffffff", text: "#4c0519", muted: "#6b7280", border: "#fda4af", name: "Burgundy" },
    # Electric / Light
    { primary: "#4f46e5", accent: "#06b6d4", bg: "#ffffff", card: "#f5f3ff", text: "#1e1b4b", muted: "#6b7280", border: "#c7d2fe", name: "Vibrant Pro" },
    # Gold / Light
    { primary: "#a16207", accent: "#854d0e", bg: "#fefce8", card: "#ffffff", text: "#422006", muted: "#78716c", border: "#fef08a", name: "Premium Gold" },
    # Ocean / Light
    { primary: "#1e3a5f", accent: "#0c4a6e", bg: "#f0f9ff", card: "#ffffff", text: "#0c4a6e", muted: "#64748b", border: "#bae6fd", name: "Deep Ocean" },
    # Peach / Light
    { primary: "#ea580c", accent: "#dc2626", bg: "#fffbeb", card: "#ffffff", text: "#431407", muted: "#78716c", border: "#fde68a", name: "Peach Sunset" },
    # Minimal Dark
    { primary: "#ffffff", accent: "#a1a1aa", bg: "#09090b", card: "#18181b", text: "#fafafa", muted: "#a1a1aa", border: "#27272a", name: "Noir" },
    # Minimal Light
    { primary: "#09090b", accent: "#71717a", bg: "#ffffff", card: "#fafafa", text: "#09090b", muted: "#71717a", border: "#e4e4e7", name: "Paper" },
  ].freeze

  FONT_COMBOS = [
    { heading: "Inter", body: "Inter", name: "Inter" },
    { heading: "Poppins", body: "Inter", name: "Poppins + Inter" },
    { heading: "Space Grotesk", body: "Inter", name: "Space Grotesk" },
    { heading: "Outfit", body: "Inter", name: "Outfit" },
    { heading: "Sora", body: "Inter", name: "Sora" },
    { heading: "DM Sans", body: "DM Sans", name: "DM Sans" },
    { heading: "Montserrat", body: "Open Sans", name: "Montserrat" },
    { heading: "Playfair Display", body: "Lato", name: "Playfair Display" },
    { heading: "Raleway", body: "Open Sans", name: "Raleway" },
    { heading: "Nunito", body: "Nunito Sans", name: "Nunito" },
    { heading: "Josefin Sans", body: "Lato", name: "Josefin Sans" },
    { heading: "Manrope", body: "Inter", name: "Manrope" },
    { heading: "Plus Jakarta Sans", body: "Inter", name: "Jakarta Sans" },
    { heading: "Clash Display", body: "DM Sans", name: "Clash Display" },
    { heading: "Cabinet Grotesk", body: "Inter", name: "Cabinet Grotesk" },
    { heading: "General Sans", body: "Inter", name: "General Sans" },
    { heading: "Satoshi", body: "Inter", name: "Satoshi" },
    { heading: "Bricolage Grotesque", body: "Inter", name: "Bricolage" },
    { heading: "Fraunces", body: "Commissioner", name: "Fraunces" },
    { heading: "Libre Baskerville", body: "Source Sans 3", name: "Baskerville" },
    { heading: "Cormorant Garamond", body: "Proza Libre", name: "Cormorant" },
    { heading: "Merriweather", body: "Open Sans", name: "Merriweather" },
    { heading: "Bebas Neue", body: "Inter", name: "Bebas Neue" },
    { heading: "Oswald", body: "Lato", name: "Oswald" },
  ].freeze

  def initialize(site, configuration = nil)
    @site = site
    @config = configuration || site.configuration
    @palette = if @config&.color_palette.present? && PALETTES[@config.color_palette]
                 PALETTES[@config.color_palette]
               else
                 PALETTES.sample
               end
    @fonts = if @config&.font_combo.present? && FONT_COMBOS[@config.font_combo]
               FONT_COMBOS[@config.font_combo]
             else
               FONT_COMBOS.sample
             end
    @business_name = @config&.business_name.presence || site.name.presence || "Your Business"
    @phone_number = @config&.phone_number.presence
    @tagline = @config&.tagline.presence || "Professional solutions tailored to your needs"
    @value_prop = @config&.value_proposition.presence || "Let us help you grow your business with proven strategies and modern tools."
    @services = @config&.services_array&.select { |s| s["name"].present? } || []
    @faqs = @config&.faqs_array&.select { |f| f["question"].present? } || []
    @about_content = @config&.about_content.presence
    @team_info = @config&.team_info.presence
    @video_url = @config&.video_url.presence
    @location_address = @config&.location_address.presence
    @service_area = @config&.service_area.presence
    @google_maps_url = @config&.google_business_profile_url.presence
    @hero_image_url = @config&.hero_image&.attached? ? rails_blob_path(@config.hero_image, only_path: true) : nil
    @team_photo_url = @config&.team_photo&.attached? ? rails_blob_path(@config.team_photo, only_path: true) : nil
    @gallery_image_urls = @config&.gallery_images&.attached? ? @config.gallery_images.map { |img| rails_blob_path(img, only_path: true) } : []
    @logo_url = @config&.logo_image&.attached? ? rails_blob_path(@config.logo_image, only_path: true) : nil
    # Base path for internal links (preview mode vs custom domain)
    @base_path = site.subdomain.present? ? "/preview/#{site.subdomain}" : ""
  end

  def generate!
    generate_page("home", "Home", 0) { build_homepage_html }
    generate_page("services", "Services", 1) { build_services_html }
    generate_page("about", "About Us", 2) { build_about_html }
    generate_page("contact", "Contact Us", 3) { build_contact_html }

    @site.update!(published: true) unless @site.published?
  end

  private

  def generate_page(slug, title, position)
    page = @site.pages.find_or_initialize_by(slug: slug)
    page.title = title
    page.status = "published"
    page.position = position
    page.html_content = yield
    page.css_content = build_css
    page.content = {}
    page.save!
  end

  # ─── HOMEPAGE ──────────────────────────────────────────────────

  def build_homepage_html
    navbar = build_navbar
    hero = build_hero_section
    bottom_cta = build_bottom_cta

    # Middle sections — randomized order
    middle_sections = []
    middle_sections << build_social_proof_section
    middle_sections << build_services_preview_section
    middle_sections << build_why_choose_us_section
    middle_sections << build_faqs_section if @faqs.any?
    middle_sections << build_about_preview_section
    middle_sections.shuffle!

    ([navbar, hero] + middle_sections + [bottom_cta, build_footer]).join("\n\n")
  end

  # ─── SERVICES PAGE ─────────────────────────────────────────────

  def build_services_html
    services_content = if @services.any?
      @services.map do |svc|
        <<~HTML
          <div class="feature-card">
            <div class="feature-icon">&#9733;</div>
            <h3 class="feature-title">#{svc['name']}</h3>
            <p class="feature-desc">#{svc['description'].presence || 'Professional service delivered with expertise and care.'}</p>
          </div>
        HTML
      end.join
    else
      <<~HTML
        <div class="feature-card">
          <div class="feature-icon">&#9733;</div>
          <h3 class="feature-title">Service One</h3>
          <p class="feature-desc">Professional service delivered with expertise and attention to detail.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">&#9889;</div>
          <h3 class="feature-title">Service Two</h3>
          <p class="feature-desc">Efficient solutions that save you time and maximize results.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">&#9825;</div>
          <h3 class="feature-title">Service Three</h3>
          <p class="feature-desc">Client-focused approach that puts your needs first.</p>
        </div>
      HTML
    end

    <<~HTML
      #{build_navbar}
      <section class="services-section" style="padding-top: 120px;">
        <div class="section-container">
          <h1 class="section-title" style="text-align: center;">Our Services</h1>
          <p class="section-subtitle" style="text-align: center; margin: 0 auto 48px;">Everything we offer to help your business succeed.</p>
          <div class="features-grid">
            #{services_content}
          </div>
        </div>
      </section>
      #{build_bottom_cta}
      #{build_footer}
    HTML
  end

  # ─── ABOUT US PAGE ─────────────────────────────────────────────

  def build_about_html
    about_text = @about_content.presence || "With years of experience in the industry, we've helped hundreds of businesses achieve their goals. Our team of experts combines creativity with technical expertise to deliver results that matter.\n\nWe believe in building long-term partnerships with our clients, providing ongoing support and innovative solutions that evolve with your business."

    team_photo_html = if @team_photo_url.present?
      <<~HTML
        <div style="text-align: center; margin-bottom: 32px;">
          <img src="#{@team_photo_url}" alt="Our Team" style="width: 100%; max-width: 700px; height: auto; border-radius: 16px; object-fit: cover; max-height: 400px;">
        </div>
      HTML
    else
      ""
    end

    team_section = if @team_info.present? || @team_photo_url.present?
      <<~HTML
        <section class="services-section">
          <div class="section-container">
            <h2 class="section-title" style="text-align: center;">Our Team</h2>
            #{team_photo_html}
            #{"<p class=\"about-desc\" style=\"max-width: 700px; margin: 0 auto; text-align: center;\">#{@team_info}</p>" if @team_info.present?}
          </div>
        </section>
      HTML
    else
      ""
    end

    <<~HTML
      #{build_navbar}
      <section class="about-section" style="padding-top: 120px;">
        <div class="section-container">
          <div class="about-grid">
            <div class="about-text">
              <h1 class="section-title">About #{@business_name}</h1>
              #{about_text.split("\n").map { |p| "<p class=\"about-desc\">#{p.strip}</p>" }.join("\n              ")}
            </div>
            <div class="about-stats">
              <div class="stat-item">
                <span class="stat-number">500+</span>
                <span class="stat-label">Happy Clients</span>
              </div>
              <div class="stat-item">
                <span class="stat-number">98%</span>
                <span class="stat-label">Satisfaction Rate</span>
              </div>
              <div class="stat-item">
                <span class="stat-number">10+</span>
                <span class="stat-label">Years Experience</span>
              </div>
            </div>
          </div>
        </div>
      </section>
      #{team_section}
      #{build_gallery_section}
      #{build_bottom_cta}
      #{build_footer}
    HTML
  end

  def build_gallery_section
    return "" if @gallery_image_urls.empty?

    images_html = @gallery_image_urls.map { |url|
      <<~HTML
        <div style="border-radius: 12px; overflow: hidden; border: 1px solid #{@palette[:border]};">
          <img src="#{url}" alt="Gallery" style="width: 100%; height: 250px; object-fit: cover; display: block;">
        </div>
      HTML
    }.join("\n")

    <<~HTML
      <section class="services-section">
        <div class="section-container">
          <h2 class="section-title" style="text-align: center;">Gallery</h2>
          <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 24px; margin-top: 40px;">
            #{images_html}
          </div>
        </div>
      </section>
    HTML
  end

  # ─── CONTACT US PAGE ───────────────────────────────────────────

  def build_contact_html
    map_section = if @google_maps_url.present?
      # Prioritize Google Maps/Business Profile URL — extract embed URL
      embed_src = extract_google_maps_embed(@google_maps_url)
      <<~HTML
        <section class="services-section">
          <div class="section-container">
            <h2 class="section-title" style="text-align: center;">Find Us</h2>
            <div style="border-radius: 16px; overflow: hidden; border: 1px solid #{@palette[:border]}; margin-top: 32px;">
              <iframe src="#{embed_src}" width="100%" height="400" style="border: 0; display: block;" allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe>
            </div>
            #{@service_area.present? ? "<p style=\"text-align: center; margin-top: 16px; color: #{@palette[:muted]}; font-size: 14px;\">Service Area: #{@service_area}</p>" : ""}
          </div>
        </section>
      HTML
    elsif @location_address.present?
      encoded_address = CGI.escape(@location_address)
      <<~HTML
        <section class="services-section">
          <div class="section-container">
            <h2 class="section-title" style="text-align: center;">Find Us</h2>
            <div style="border-radius: 16px; overflow: hidden; border: 1px solid #{@palette[:border]}; margin-top: 32px;">
              <iframe src="https://www.google.com/maps?q=#{encoded_address}&output=embed" width="100%" height="400" style="border: 0; display: block;" allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe>
            </div>
            #{@service_area.present? ? "<p style=\"text-align: center; margin-top: 16px; color: #{@palette[:muted]}; font-size: 14px;\">Service Area: #{@service_area}</p>" : ""}
          </div>
        </section>
      HTML
    elsif @service_area.present?
      <<~HTML
        <section class="services-section">
          <div class="section-container" style="text-align: center;">
            <h2 class="section-title">Service Area</h2>
            <p class="about-desc" style="max-width: 500px; margin: 0 auto;">We proudly serve the #{@service_area}.</p>
          </div>
        </section>
      HTML
    else
      ""
    end

    <<~HTML
      #{build_navbar}
      <section class="contact-section" style="padding-top: 120px;">
        <div class="section-container">
          <h1 class="section-title" style="text-align: center;">Get in Touch</h1>
          <p class="section-subtitle" style="text-align: center; margin: 0 auto 48px;">We'd love to hear from you. Send us a message and we'll respond as soon as possible.</p>
          <form class="contact-form" style="margin: 0 auto;">
            <div class="form-row">
              <input type="text" placeholder="Your Name" class="form-input">
              <input type="email" placeholder="Your Email" class="form-input">
            </div>
            <input type="text" placeholder="Subject" class="form-input">
            <textarea placeholder="Your Message" rows="5" class="form-input form-textarea"></textarea>
            <button type="submit" class="btn-primary">Send Message</button>
          </form>
        </div>
      </section>
      #{map_section}
      #{build_footer}
    HTML
  end

  # ─── SHARED COMPONENTS ─────────────────────────────────────────

  def build_navbar
    <<~HTML
      <nav class="navbar">
        <div class="nav-container">
          <a href="#{@base_path}/home" class="nav-logo">#{@logo_url ? "<img src=\"#{@logo_url}\" alt=\"#{@business_name}\" style=\"height: 36px; width: auto;\">" : @business_name}</a>
          <div class="nav-links">
            <a href="#{@base_path}/home" class="nav-link">Home</a>
            <a href="#{@base_path}/services" class="nav-link">Services</a>
            <a href="#{@base_path}/about" class="nav-link">About</a>
            <a href="#{@base_path}/contact" class="nav-link nav-cta">Contact Us</a>
          </div>
        </div>
      </nav>
    HTML
  end

  def build_hero_section
    media_embed = if @video_url.present?
      embed_url = convert_video_url(@video_url)
      <<~HTML
        <div class="hero-video">
          <iframe src="#{embed_url}" width="100%" height="400" frameborder="0" allow="autoplay; fullscreen" allowfullscreen style="border-radius: 16px; margin-top: 48px; max-width: 800px;"></iframe>
        </div>
      HTML
    elsif @hero_image_url.present?
      <<~HTML
        <div class="hero-image" style="width: 100%; margin: 48px 0 0;">
          <img src="#{@hero_image_url}" alt="#{@business_name}" style="width: 100%; height: auto; border-radius: 16px; object-fit: cover; max-height: 560px;">
        </div>
      HTML
    else
      ""
    end

    <<~HTML
      <section class="hero-section">
        #{media_embed}
        <div class="hero-content">
          <h1 class="hero-title">#{@business_name}</h1>
          <p class="hero-tagline">#{@tagline}</p>
          <p class="hero-subtitle">#{@value_prop}</p>
          <div class="hero-buttons">
            <a href="#{@base_path}/contact" class="btn-primary">Get Started</a>
            <a href="#{@base_path}/services" class="btn-secondary">Our Services</a>
          </div>
        </div>
      </section>
    HTML
  end

  def build_social_proof_section
    <<~HTML
      <section class="testimonials-section">
        <div class="section-container">
          <h2 class="section-title" style="text-align: center;">What Our Clients Say</h2>
          <p class="section-subtitle" style="text-align: center; margin: 0 auto 48px;">Don't just take our word for it.</p>
          <div class="testimonials-grid">
            <div class="testimonial-card">
              <div class="testimonial-stars">&#9733;&#9733;&#9733;&#9733;&#9733;</div>
              <p class="testimonial-text">"Absolutely outstanding service. They exceeded our expectations and delivered results that transformed our business."</p>
              <div class="testimonial-author">
                <div class="author-avatar">JD</div>
                <div>
                  <p class="author-name">Jane Doe</p>
                  <p class="author-role">CEO, TechCorp</p>
                </div>
              </div>
            </div>
            <div class="testimonial-card">
              <div class="testimonial-stars">&#9733;&#9733;&#9733;&#9733;&#9733;</div>
              <p class="testimonial-text">"Professional, responsive, and incredibly talented. Couldn't recommend them more highly."</p>
              <div class="testimonial-author">
                <div class="author-avatar">JS</div>
                <div>
                  <p class="author-name">John Smith</p>
                  <p class="author-role">Founder, StartupXYZ</p>
                </div>
              </div>
            </div>
            <div class="testimonial-card">
              <div class="testimonial-stars">&#9733;&#9733;&#9733;&#9733;&#9733;</div>
              <p class="testimonial-text">"They understood our vision perfectly and delivered beyond what we imagined possible."</p>
              <div class="testimonial-author">
                <div class="author-avatar">MR</div>
                <div>
                  <p class="author-name">Maria Rodriguez</p>
                  <p class="author-role">Director, GrowthCo</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    HTML
  end

  def build_services_preview_section
    cards = if @services.any?
      @services.first(3).map.with_index do |svc, i|
        icons = ["&#9733;", "&#9889;", "&#9825;", "&#10024;", "&#9992;", "&#9881;"]
        <<~HTML
          <div class="feature-card">
            <div class="feature-icon">#{icons[i % icons.length]}</div>
            <h3 class="feature-title">#{svc['name']}</h3>
            <p class="feature-desc">#{svc['description'].presence || 'Professional service delivered with expertise.'}</p>
          </div>
        HTML
      end.join
    else
      <<~HTML
        <div class="feature-card">
          <div class="feature-icon">&#9733;</div>
          <h3 class="feature-title">Quality Service</h3>
          <p class="feature-desc">We deliver exceptional results with attention to detail and commitment to excellence.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">&#9889;</div>
          <h3 class="feature-title">Fast Delivery</h3>
          <p class="feature-desc">Time is money. We work efficiently to deliver on schedule without compromising quality.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">&#9825;</div>
          <h3 class="feature-title">Client Focused</h3>
          <p class="feature-desc">Your success is our priority. We deliver solutions that match your unique needs.</p>
        </div>
      HTML
    end

    <<~HTML
      <section id="services" class="services-section">
        <div class="section-container">
          <h2 class="section-title" style="text-align: center;">What We Offer</h2>
          <p class="section-subtitle" style="text-align: center; margin: 0 auto 48px;">Everything you need to succeed, all in one place.</p>
          <div class="features-grid">
            #{cards}
          </div>
          <div style="text-align: center; margin-top: 40px;">
            <a href="#{@base_path}/services" class="btn-secondary">View All Services</a>
          </div>
        </div>
      </section>
    HTML
  end

  def build_why_choose_us_section
    <<~HTML
      <section class="about-section">
        <div class="section-container">
          <h2 class="section-title" style="text-align: center; margin-bottom: 48px;">Why Choose #{@business_name}?</h2>
          <div class="benefits-grid">
            <div class="benefit-item">
              <div class="benefit-number">01</div>
              <h3 class="feature-title">Proven Track Record</h3>
              <p class="feature-desc">Years of experience delivering consistent results for businesses like yours.</p>
            </div>
            <div class="benefit-item">
              <div class="benefit-number">02</div>
              <h3 class="feature-title">Personalized Approach</h3>
              <p class="feature-desc">Every solution is tailored to your specific goals and challenges.</p>
            </div>
            <div class="benefit-item">
              <div class="benefit-number">03</div>
              <h3 class="feature-title">Transparent Process</h3>
              <p class="feature-desc">Clear communication and no surprises — you're always in the loop.</p>
            </div>
            <div class="benefit-item">
              <div class="benefit-number">04</div>
              <h3 class="feature-title">Ongoing Support</h3>
              <p class="feature-desc">We don't disappear after delivery. Count on us for long-term partnership.</p>
            </div>
          </div>
        </div>
      </section>
    HTML
  end

  def build_faqs_section
    faq_items = if @faqs.any?
      @faqs.map do |faq|
        <<~HTML
          <div class="faq-item">
            <h3 class="faq-question">#{faq['question']}</h3>
            <p class="faq-answer">#{faq['answer']}</p>
          </div>
        HTML
      end.join
    else
      <<~HTML
        <div class="faq-item">
          <h3 class="faq-question">What services do you offer?</h3>
          <p class="faq-answer">We offer a comprehensive range of professional services designed to help businesses grow and succeed.</p>
        </div>
        <div class="faq-item">
          <h3 class="faq-question">How long does a typical project take?</h3>
          <p class="faq-answer">Project timelines vary based on complexity, but we always provide clear estimates upfront and keep you informed throughout.</p>
        </div>
        <div class="faq-item">
          <h3 class="faq-question">Do you offer ongoing support?</h3>
          <p class="faq-answer">Absolutely! We provide ongoing support and maintenance to ensure your continued success after project completion.</p>
        </div>
      HTML
    end

    <<~HTML
      <section class="services-section">
        <div class="section-container">
          <h2 class="section-title" style="text-align: center;">Frequently Asked Questions</h2>
          <p class="section-subtitle" style="text-align: center; margin: 0 auto 48px;">Got questions? We've got answers.</p>
          <div class="faqs-list">
            #{faq_items}
          </div>
        </div>
      </section>
    HTML
  end

  def build_about_preview_section
    text = @about_content.presence || "We're a team of passionate professionals dedicated to helping businesses grow. With expertise across multiple disciplines, we deliver comprehensive solutions."

    <<~HTML
      <section class="about-section">
        <div class="section-container">
          <div class="about-grid">
            <div class="about-text">
              <h2 class="section-title">About #{@business_name}</h2>
              <p class="about-desc">#{text.split("\n").first}</p>
              <a href="#{@base_path}/about" class="btn-secondary" style="margin-top: 16px;">Learn More About Us</a>
            </div>
            <div class="about-stats">
              <div class="stat-item">
                <span class="stat-number">500+</span>
                <span class="stat-label">Happy Clients</span>
              </div>
              <div class="stat-item">
                <span class="stat-number">98%</span>
                <span class="stat-label">Satisfaction</span>
              </div>
              <div class="stat-item">
                <span class="stat-number">10+</span>
                <span class="stat-label">Years</span>
              </div>
            </div>
          </div>
        </div>
      </section>
    HTML
  end

  def build_bottom_cta
    <<~HTML
      <section class="cta-section">
        <div class="section-container cta-content">
          <h2 class="cta-title">Ready to Get Started?</h2>
          <p class="cta-subtitle">Let's discuss how we can help your business grow.</p>
          <form class="contact-form" style="margin: 0 auto;">
            <div class="form-row">
              <input type="text" placeholder="Your Name" class="form-input">
              <input type="email" placeholder="Your Email" class="form-input">
            </div>
            <textarea placeholder="Tell us about your project..." rows="3" class="form-input form-textarea"></textarea>
            <button type="submit" class="btn-primary">Get in Touch</button>
          </form>
        </div>
      </section>
    HTML
  end

  def build_footer
    <<~HTML
      <footer class="footer-section">
        <div class="section-container footer-content">
          <div class="footer-brand">
            <h3 class="footer-logo">#{@business_name}</h3>
            <p class="footer-tagline">#{@tagline}</p>
          </div>
          <div class="footer-links">
            <a href="#{@base_path}/home">Home</a>
            <a href="#{@base_path}/services">Services</a>
            <a href="#{@base_path}/about">About</a>
            <a href="#{@base_path}/contact">Contact</a>
          </div>
          <div class="footer-bottom">
            <p>&copy; #{Date.current.year} #{@business_name}. All rights reserved.</p>
          </div>
        </div>
      </footer>
      #{build_mobile_floating_buttons}
    HTML
  end

  def build_mobile_floating_buttons
    return "" unless @phone_number.present?

    # Clean phone number for tel: link (remove spaces, parentheses, dashes)
    clean_phone = @phone_number.gsub(/[^0-9+]/, "")

    <<~HTML
      <div class="mobile-floating-buttons">
        <a href="tel:#{clean_phone}" class="floating-btn floating-btn-call" aria-label="Call us">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
          </svg>
        </a>
        <a href="#{@base_path}/contact" class="floating-btn floating-btn-contact" aria-label="Contact us">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"></path>
          </svg>
        </a>
      </div>
    HTML
  end

  # ─── CSS ───────────────────────────────────────────────────────

  def build_css
    <<~CSS
      @import url('https://fonts.googleapis.com/css2?family=#{@fonts[:heading].gsub(' ', '+')}:wght@400;600;700;800&family=#{@fonts[:body].gsub(' ', '+')}:wght@300;400;500;600&display=swap');

      * { margin: 0; padding: 0; box-sizing: border-box; }

      body {
        font-family: '#{@fonts[:body]}', sans-serif;
        background: #{@palette[:bg]};
        color: #{@palette[:text]};
        line-height: 1.6;
      }

      /* Navbar */
      .navbar {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        z-index: 1000;
        background: #{@palette[:bg]}ee;
        backdrop-filter: blur(12px);
        border-bottom: 1px solid #{@palette[:border]};
        padding: 16px 24px;
      }

      .nav-container {
        max-width: 1100px;
        margin: 0 auto;
        display: flex;
        align-items: center;
        justify-content: space-between;
      }

      .nav-logo {
        font-family: '#{@fonts[:heading]}', sans-serif;
        font-size: 20px;
        font-weight: 700;
        color: #{@palette[:text]};
        text-decoration: none;
      }

      .nav-links { display: flex; align-items: center; gap: 32px; }

      .nav-link {
        font-size: 14px;
        color: #{@palette[:muted]};
        text-decoration: none;
        font-weight: 500;
        transition: color 0.2s;
      }

      .nav-link:hover { color: #{@palette[:text]}; }

      .nav-cta {
        padding: 8px 20px;
        background: #{@palette[:primary]};
        color: #fff !important;
        border-radius: 8px;
        font-weight: 600;
      }

      .nav-cta:hover { opacity: 0.9; }

      .section-container {
        max-width: 1100px;
        margin: 0 auto;
        padding: 0 24px;
      }

      .section-title {
        font-family: '#{@fonts[:heading]}', sans-serif;
        font-size: 36px;
        font-weight: 700;
        margin-bottom: 12px;
        color: #{@palette[:text]};
      }

      .section-subtitle {
        font-size: 16px;
        color: #{@palette[:muted]};
        margin-bottom: 48px;
        max-width: 600px;
      }

      /* Hero */
      .hero-section {
        padding: 160px 0 100px;
        text-align: center;
        background: linear-gradient(180deg, #{@palette[:bg]} 0%, #{@palette[:card]} 100%);
      }

      .hero-content { max-width: 800px; margin: 0 auto; padding: 0 24px; }

      .hero-title {
        font-family: '#{@fonts[:heading]}', sans-serif;
        font-size: 56px;
        font-weight: 800;
        margin-bottom: 16px;
        background: linear-gradient(135deg, #{@palette[:text]} 0%, #{@palette[:primary]} 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
      }

      .hero-tagline {
        font-family: '#{@fonts[:heading]}', sans-serif;
        font-size: 22px;
        font-weight: 600;
        color: #{@palette[:primary]};
        margin-bottom: 16px;
      }

      .hero-subtitle {
        font-size: 18px;
        color: #{@palette[:muted]};
        margin-bottom: 36px;
        line-height: 1.7;
      }

      .hero-buttons { display: flex; gap: 16px; justify-content: center; flex-wrap: wrap; }

      .hero-video { display: flex; justify-content: center; }

      .btn-primary {
        display: inline-block;
        padding: 14px 32px;
        background: #{@palette[:primary]};
        color: #fff;
        border-radius: 10px;
        text-decoration: none;
        font-weight: 600;
        font-size: 15px;
        border: none;
        cursor: pointer;
        transition: opacity 0.2s, transform 0.2s;
      }

      .btn-primary:hover { opacity: 0.9; transform: translateY(-1px); }

      .btn-secondary {
        display: inline-block;
        padding: 14px 32px;
        background: transparent;
        color: #{@palette[:muted]};
        border: 1px solid #{@palette[:border]};
        border-radius: 10px;
        text-decoration: none;
        font-weight: 600;
        font-size: 15px;
        transition: border-color 0.2s, color 0.2s;
      }

      .btn-secondary:hover { border-color: #{@palette[:primary]}; color: #{@palette[:text]}; }

      .btn-large { padding: 16px 40px; font-size: 16px; }

      /* Services / Features */
      .services-section { padding: 100px 24px; }

      .features-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 24px;
      }

      .feature-card {
        padding: 36px;
        background: #{@palette[:card]};
        border-radius: 16px;
        border: 1px solid #{@palette[:border]};
        transition: border-color 0.2s, transform 0.2s;
      }

      .feature-card:hover { border-color: #{@palette[:primary]}; transform: translateY(-2px); }

      .feature-icon {
        width: 48px;
        height: 48px;
        background: #{@palette[:primary]};
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        margin-bottom: 20px;
        color: #fff;
      }

      .feature-title {
        font-family: '#{@fonts[:heading]}', sans-serif;
        font-size: 18px;
        font-weight: 600;
        margin-bottom: 10px;
        color: #{@palette[:text]};
      }

      .feature-desc { font-size: 14px; color: #{@palette[:muted]}; line-height: 1.7; }

      /* Why Choose Us / Benefits */
      .benefits-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 32px;
        max-width: 900px;
        margin: 0 auto;
      }

      .benefit-item { padding: 24px; }

      .benefit-number {
        font-family: '#{@fonts[:heading]}', sans-serif;
        font-size: 32px;
        font-weight: 800;
        color: #{@palette[:primary]};
        margin-bottom: 12px;
      }

      /* About */
      .about-section { padding: 100px 24px; background: #{@palette[:card]}; }

      .about-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 60px;
        align-items: center;
      }

      .about-desc { font-size: 15px; color: #{@palette[:muted]}; margin-bottom: 16px; line-height: 1.8; }

      .about-stats {
        display: grid;
        grid-template-columns: 1fr;
        gap: 24px;
      }

      .stat-item {
        text-align: center;
        padding: 24px;
        background: #{@palette[:bg]};
        border-radius: 12px;
        border: 1px solid #{@palette[:border]};
      }

      .stat-number {
        display: block;
        font-family: '#{@fonts[:heading]}', sans-serif;
        font-size: 36px;
        font-weight: 800;
        color: #{@palette[:primary]};
        margin-bottom: 4px;
      }

      .stat-label { font-size: 13px; color: #{@palette[:muted]}; text-transform: uppercase; letter-spacing: 1px; }

      /* Testimonials */
      .testimonials-section { padding: 100px 24px; }

      .testimonials-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 24px;
      }

      .testimonial-card {
        padding: 32px;
        background: #{@palette[:card]};
        border-radius: 16px;
        border: 1px solid #{@palette[:border]};
      }

      .testimonial-stars {
        color: #{@palette[:primary]};
        font-size: 18px;
        margin-bottom: 16px;
      }

      .testimonial-text {
        font-size: 15px;
        color: #{@palette[:muted]};
        font-style: italic;
        margin-bottom: 20px;
        line-height: 1.7;
      }

      .testimonial-author { display: flex; align-items: center; gap: 12px; }

      .author-avatar {
        width: 40px;
        height: 40px;
        background: #{@palette[:primary]};
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 13px;
        font-weight: 600;
        color: #fff;
      }

      .author-name { font-size: 14px; font-weight: 600; color: #{@palette[:text]}; }
      .author-role { font-size: 12px; color: #{@palette[:muted]}; }

      /* FAQs */
      .faqs-list {
        max-width: 700px;
        margin: 0 auto;
        display: flex;
        flex-direction: column;
        gap: 16px;
      }

      .faq-item {
        padding: 24px;
        background: #{@palette[:card]};
        border-radius: 12px;
        border: 1px solid #{@palette[:border]};
      }

      .faq-question {
        font-family: '#{@fonts[:heading]}', sans-serif;
        font-size: 16px;
        font-weight: 600;
        color: #{@palette[:text]};
        margin-bottom: 8px;
      }

      .faq-answer {
        font-size: 14px;
        color: #{@palette[:muted]};
        line-height: 1.7;
      }

      /* CTA */
      .cta-section {
        padding: 100px 24px;
        background: linear-gradient(135deg, #{@palette[:primary]}22, #{@palette[:accent]}22);
      }

      .cta-content { text-align: center; }
      .cta-title { font-family: '#{@fonts[:heading]}', sans-serif; font-size: 40px; font-weight: 700; margin-bottom: 12px; }
      .cta-subtitle { font-size: 16px; color: #{@palette[:muted]}; margin-bottom: 36px; }

      /* Contact */
      .contact-section { padding: 100px 24px; background: #{@palette[:card]}; }

      .contact-form { max-width: 600px; display: flex; flex-direction: column; gap: 16px; }

      .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }

      .form-input {
        padding: 14px 16px;
        background: #{@palette[:bg]};
        border: 1px solid #{@palette[:border]};
        border-radius: 10px;
        color: #{@palette[:text]};
        font-size: 14px;
        font-family: '#{@fonts[:body]}', sans-serif;
        outline: none;
        transition: border-color 0.2s;
      }

      .form-input:focus { border-color: #{@palette[:primary]}; }
      .form-textarea { resize: vertical; min-height: 120px; }

      /* Footer */
      .footer-section { padding: 60px 24px 40px; border-top: 1px solid #{@palette[:border]}; }

      .footer-content { text-align: center; }
      .footer-logo { font-family: '#{@fonts[:heading]}', sans-serif; font-size: 20px; font-weight: 700; margin-bottom: 8px; }
      .footer-tagline { font-size: 14px; color: #{@palette[:muted]}; margin-bottom: 24px; }

      .footer-links { display: flex; gap: 24px; justify-content: center; margin-bottom: 32px; }
      .footer-links a { color: #{@palette[:muted]}; text-decoration: none; font-size: 14px; transition: color 0.2s; }
      .footer-links a:hover { color: #{@palette[:primary]}; }

      .footer-bottom { padding-top: 24px; border-top: 1px solid #{@palette[:border]}; }
      .footer-bottom p { font-size: 12px; color: #{@palette[:muted]}; }

      /* Responsive */
      @media (max-width: 768px) {
        .hero-title { font-size: 36px; }
        .hero-tagline { font-size: 18px; }
        .hero-subtitle { font-size: 16px; }
        .hero-section { padding-top: 120px; }
        .about-grid { grid-template-columns: 1fr; gap: 40px; }
        .form-row { grid-template-columns: 1fr; }
        .section-title { font-size: 28px; }
        .cta-title { font-size: 28px; }
        .nav-links { gap: 16px; }
        .benefits-grid { grid-template-columns: 1fr; }

        /* Mobile Floating Buttons */
        .mobile-floating-buttons {
          position: fixed;
          bottom: 20px;
          right: 20px;
          display: flex;
          flex-direction: column;
          gap: 12px;
          z-index: 1000;
        }

        .floating-btn {
          width: 56px;
          height: 56px;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
          transition: transform 0.2s, box-shadow 0.2s;
        }

        .floating-btn:hover {
          transform: scale(1.05);
          box-shadow: 0 6px 16px rgba(0, 0, 0, 0.2);
        }

        .floating-btn-call {
          background: #{@palette[:primary]};
          color: white;
        }

        .floating-btn-contact {
          background: #{@palette[:card]};
          color: #{@palette[:text]};
          border: 1px solid #{@palette[:border]};
        }
      }

      /* Hide floating buttons on desktop */
      @media (min-width: 769px) {
        .mobile-floating-buttons { display: none; }
      }
    CSS
  end

  # ─── HELPERS ───────────────────────────────────────────────────

  def convert_video_url(url)
    if url.include?("youtube.com/watch")
      video_id = url[/[?&]v=([^&]+)/, 1]
      "https://www.youtube.com/embed/#{video_id}"
    elsif url.include?("youtube.com/shorts/")
      video_id = url.split("shorts/").last.split("?").first
      "https://www.youtube.com/embed/#{video_id}"
    elsif url.include?("youtu.be/")
      video_id = url.split("youtu.be/").last.split("?").first
      "https://www.youtube.com/embed/#{video_id}"
    elsif url.include?("vimeo.com/")
      video_id = url.split("vimeo.com/").last.split("?").first
      "https://player.vimeo.com/video/#{video_id}"
    else
      url
    end
  end

  def extract_google_maps_embed(url)
    # Resolve shortened URLs (maps.app.goo.gl, goo.gl) by following redirects
    resolved_url = resolve_short_url(url)

    # Extract a searchable query from various Google Maps URL formats
    query = nil

    if resolved_url =~ %r{/maps/place/([^/@]+)}
      # https://www.google.com/maps/place/Place+Name/...
      query = URI.decode_www_form_component($1.gsub("+", " "))
    elsif resolved_url =~ %r{/@(-?\d+\.\d+),(-?\d+\.\d+)}
      # URL contains coordinates: .../@lat,lng,...
      query = "#{$1},#{$2}"
    elsif resolved_url =~ /[?&]q=([^&]+)/
      # URL has ?q= parameter
      query = URI.decode_www_form_component($1)
    elsif resolved_url =~ /[?&]cid=(\d+)/
      # Business Profile CID — use as-is with Google search
      query = resolved_url
    end

    if query.present?
      "https://maps.google.com/maps?q=#{CGI.escape(query)}&output=embed"
    else
      # Fallback: use the location address if available, otherwise the URL
      fallback = @location_address.presence || resolved_url
      "https://maps.google.com/maps?q=#{CGI.escape(fallback)}&output=embed"
    end
  end

  def resolve_short_url(url)
    return url unless url.include?("goo.gl") || url.include?("bit.ly") || url.include?("maps.app")

    uri = URI.parse(url)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 3, read_timeout: 3) do |http|
      http.head(uri.request_uri)
    end

    if response.is_a?(Net::HTTPRedirection) && response["location"]
      response["location"]
    else
      url
    end
  rescue StandardError
    url
  end
end
