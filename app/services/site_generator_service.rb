class SiteGeneratorService
  PALETTES = [
    { primary: "#6366f1", accent: "#06b6d4", bg: "#0f172a", card: "#1e293b", text: "#f8fafc", muted: "#94a3b8", border: "#334155" },
    { primary: "#f97316", accent: "#eab308", bg: "#1c1917", card: "#292524", text: "#fafaf9", muted: "#a8a29e", border: "#44403c" },
    { primary: "#ec4899", accent: "#8b5cf6", bg: "#0f0518", card: "#1a0a2e", text: "#faf5ff", muted: "#a78bfa", border: "#3b0764" },
    { primary: "#10b981", accent: "#06b6d4", bg: "#022c22", card: "#064e3b", text: "#ecfdf5", muted: "#6ee7b7", border: "#065f46" },
    { primary: "#3b82f6", accent: "#8b5cf6", bg: "#0f172a", card: "#1e293b", text: "#f8fafc", muted: "#93c5fd", border: "#1e3a5f" },
    { primary: "#f43f5e", accent: "#fb923c", bg: "#1a0005", card: "#2d0a0a", text: "#fff1f2", muted: "#fda4af", border: "#4c0519" },
    { primary: "#14b8a6", accent: "#a3e635", bg: "#042f2e", card: "#134e4a", text: "#f0fdfa", muted: "#5eead4", border: "#115e59" },
    { primary: "#f59e0b", accent: "#ef4444", bg: "#1c1917", card: "#292524", text: "#fffbeb", muted: "#fcd34d", border: "#44403c" },
  ].freeze

  FONT_COMBOS = [
    { heading: "Inter", body: "Inter" },
    { heading: "Poppins", body: "Inter" },
    { heading: "Space Grotesk", body: "Inter" },
    { heading: "Outfit", body: "Inter" },
    { heading: "Sora", body: "Inter" },
    { heading: "DM Sans", body: "DM Sans" },
    { heading: "Montserrat", body: "Open Sans" },
    { heading: "Playfair Display", body: "Lato" },
  ].freeze

  def initialize(site)
    @site = site
    @palette = PALETTES.sample
    @fonts = FONT_COMBOS.sample
    @business_name = site.name.presence || "Your Business"
  end

  def generate!
    page = @site.pages.find_or_initialize_by(slug: "index")
    page.title = "Home"
    page.status = "published"
    page.position = 0

    html = build_html
    css = build_css

    page.html_content = html
    page.css_content = css
    page.content = {} # GrapeJS will reload from html_content
    page.save!

    @site.update!(published: true) unless @site.published?
    page
  end

  private

  def build_html
    <<~HTML
      <section class="hero-section">
        <div class="hero-content">
          <h1 class="hero-title">#{@business_name}</h1>
          <p class="hero-subtitle">Professional solutions tailored to your needs. Let us help you grow your business with proven strategies and modern tools.</p>
          <div class="hero-buttons">
            <a href="#contact" class="btn-primary">Get Started</a>
            <a href="#services" class="btn-secondary">Learn More</a>
          </div>
        </div>
      </section>

      <section id="services" class="services-section">
        <div class="section-container">
          <h2 class="section-title">What We Offer</h2>
          <p class="section-subtitle">Everything you need to succeed, all in one place.</p>
          <div class="features-grid">
            <div class="feature-card">
              <div class="feature-icon">&#9733;</div>
              <h3 class="feature-title">Quality Service</h3>
              <p class="feature-desc">We deliver exceptional results with attention to detail and a commitment to excellence in everything we do.</p>
            </div>
            <div class="feature-card">
              <div class="feature-icon">&#9889;</div>
              <h3 class="feature-title">Fast Delivery</h3>
              <p class="feature-desc">Time is money. We work efficiently to deliver your projects on schedule without compromising quality.</p>
            </div>
            <div class="feature-card">
              <div class="feature-icon">&#9825;</div>
              <h3 class="feature-title">Client Focused</h3>
              <p class="feature-desc">Your success is our priority. We listen, adapt, and deliver solutions that match your unique needs.</p>
            </div>
          </div>
        </div>
      </section>

      <section class="about-section">
        <div class="section-container">
          <div class="about-grid">
            <div class="about-text">
              <h2 class="section-title">About Us</h2>
              <p class="about-desc">With years of experience in the industry, we've helped hundreds of businesses achieve their goals. Our team of experts combines creativity with technical expertise to deliver results that matter.</p>
              <p class="about-desc">We believe in building long-term partnerships with our clients, providing ongoing support and innovative solutions that evolve with your business.</p>
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

      <section class="testimonials-section">
        <div class="section-container">
          <h2 class="section-title">What Our Clients Say</h2>
          <div class="testimonials-grid">
            <div class="testimonial-card">
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
              <p class="testimonial-text">"Professional, responsive, and incredibly talented. I couldn't recommend them more highly to anyone looking to level up."</p>
              <div class="testimonial-author">
                <div class="author-avatar">JS</div>
                <div>
                  <p class="author-name">John Smith</p>
                  <p class="author-role">Founder, StartupXYZ</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="cta-section">
        <div class="section-container cta-content">
          <h2 class="cta-title">Ready to Get Started?</h2>
          <p class="cta-subtitle">Join hundreds of satisfied clients and take your business to the next level today.</p>
          <a href="#contact" class="btn-primary btn-large">Contact Us Now</a>
        </div>
      </section>

      <section id="contact" class="contact-section">
        <div class="section-container">
          <h2 class="section-title">Get in Touch</h2>
          <p class="section-subtitle">We'd love to hear from you. Send us a message and we'll respond as soon as possible.</p>
          <form class="contact-form">
            <div class="form-row">
              <input type="text" placeholder="Your Name" class="form-input">
              <input type="email" placeholder="Your Email" class="form-input">
            </div>
            <textarea placeholder="Your Message" rows="4" class="form-input form-textarea"></textarea>
            <button type="submit" class="btn-primary">Send Message</button>
          </form>
        </div>
      </section>

      <footer class="footer-section">
        <div class="section-container footer-content">
          <div class="footer-brand">
            <h3 class="footer-logo">#{@business_name}</h3>
            <p class="footer-tagline">Professional solutions for modern businesses.</p>
          </div>
          <div class="footer-links">
            <a href="#services">Services</a>
            <a href="#contact">Contact</a>
          </div>
          <div class="footer-bottom">
            <p>&copy; #{Date.current.year} #{@business_name}. All rights reserved.</p>
          </div>
        </div>
      </footer>
    HTML
  end

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
        padding: 120px 24px 100px;
        text-align: center;
        background: linear-gradient(180deg, #{@palette[:bg]} 0%, #{@palette[:card]} 100%);
      }

      .hero-content { max-width: 700px; margin: 0 auto; }

      .hero-title {
        font-family: '#{@fonts[:heading]}', sans-serif;
        font-size: 56px;
        font-weight: 800;
        margin-bottom: 20px;
        background: linear-gradient(135deg, #{@palette[:text]} 0%, #{@palette[:primary]} 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
      }

      .hero-subtitle {
        font-size: 18px;
        color: #{@palette[:muted]};
        margin-bottom: 36px;
        line-height: 1.7;
      }

      .hero-buttons { display: flex; gap: 16px; justify-content: center; flex-wrap: wrap; }

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
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 24px;
      }

      .testimonial-card {
        padding: 32px;
        background: #{@palette[:card]};
        border-radius: 16px;
        border: 1px solid #{@palette[:border]};
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
        .hero-subtitle { font-size: 16px; }
        .about-grid { grid-template-columns: 1fr; gap: 40px; }
        .form-row { grid-template-columns: 1fr; }
        .section-title { font-size: 28px; }
        .cta-title { font-size: 28px; }
      }
    CSS
  end
end
