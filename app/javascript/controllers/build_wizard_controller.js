import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "step", "indicator", "prevBtn", "nextBtn", "submitBtn",
    "taglineField", "valuePropositionField", "aboutField", "teamInfoField"
  ]
  static values = {
    current: { type: Number, default: 0 },
    generateUrl: String,
    aiConfigured: { type: Boolean, default: false }
  }

  connect() {
    this.totalSteps = this.stepTargets.length
    this.showStep(0)
  }

  next() {
    if (this.currentValue < this.totalSteps - 1) {
      this.currentValue++
      this.showStep(this.currentValue)
    }
  }

  prev() {
    if (this.currentValue > 0) {
      this.currentValue--
      this.showStep(this.currentValue)
    }
  }

  goToStep(event) {
    const step = parseInt(event.currentTarget.dataset.step)
    if (step >= 0 && step < this.totalSteps) {
      this.currentValue = step
      this.showStep(step)
    }
  }

  showStep(index) {
    this.stepTargets.forEach((el, i) => {
      el.classList.toggle("hidden", i !== index)
    })

    this.indicatorTargets.forEach((el, i) => {
      if (i < index) {
        el.classList.remove("bg-brand-card-alt", "dark:bg-slate-700", "text-brand-text-light", "dark:text-slate-400")
        el.classList.add("bg-emerald-500", "text-white")
      } else if (i === index) {
        el.classList.remove("bg-brand-card-alt", "dark:bg-slate-700", "text-brand-text-light", "dark:text-slate-400", "bg-emerald-500")
        el.classList.add("bg-brand-highlight", "text-white")
      } else {
        el.classList.remove("bg-brand-highlight", "bg-emerald-500", "text-white")
        el.classList.add("bg-brand-card-alt", "dark:bg-slate-700", "text-brand-text-light", "dark:text-slate-400")
      }
    })

    if (this.hasPrevBtnTarget) {
      this.prevBtnTarget.style.display = index === 0 ? "none" : "inline-flex"
    }
    if (this.hasNextBtnTarget) {
      this.nextBtnTarget.style.display = index >= this.totalSteps - 1 ? "none" : "inline-flex"
    }
    if (this.hasSubmitBtnTarget) {
      this.submitBtnTarget.style.display = index === this.totalSteps - 1 ? "inline-flex" : "none"
    }
  }

  // ─── AI CONTENT GENERATION ──────────────────────────────────

  async generateAi(event) {
    const btn = event.currentTarget
    const section = btn.dataset.section
    const originalHtml = btn.innerHTML

    // Show loading state
    btn.disabled = true
    btn.innerHTML = `<svg class="w-3.5 h-3.5 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path></svg> Generating...`

    try {
      const businessName = this._getFieldValue("site_configuration_business_name") || ""
      const industry = this._getFieldValue("site_configuration_industry") || ""

      const body = {
        section: section,
        business_name: businessName,
        industry: industry,
        authenticity_token: this._csrfToken()
      }

      // Add context for services/faqs
      if (section === "faqs") {
        body.services_context = this._collectServiceNames()
        body.count = 4
      }
      if (section === "services") {
        body.count = 4
      }

      const response = await fetch(this.generateUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this._csrfToken(),
          "Accept": "application/json"
        },
        body: JSON.stringify(body)
      })

      const data = await response.json()

      if (!response.ok) {
        alert(data.error || "AI generation failed. Please try again.")
        return
      }

      this._applyContent(section, data.content)
    } catch (e) {
      alert("AI generation failed: " + e.message)
    } finally {
      btn.disabled = false
      btn.innerHTML = originalHtml
    }
  }

  _applyContent(section, content) {
    switch (section) {
      case "tagline":
        if (this.hasTaglineFieldTarget) this.taglineFieldTarget.value = content
        break
      case "value_proposition":
        if (this.hasValuePropositionFieldTarget) this.valuePropositionFieldTarget.value = content
        break
      case "about":
        if (this.hasAboutFieldTarget) this.aboutFieldTarget.value = content
        break
      case "team_info":
        if (this.hasTeamInfoFieldTarget) this.teamInfoFieldTarget.value = content
        break
      case "services":
        this._applyServices(content)
        break
      case "faqs":
        this._applyFaqs(content)
        break
    }
  }

  _applyServices(content) {
    try {
      const services = typeof content === "string" ? JSON.parse(content) : content
      if (!Array.isArray(services)) return

      const container = document.getElementById("services-container")
      container.innerHTML = ""
      services.forEach(svc => {
        container.insertAdjacentHTML("beforeend", this._serviceEntryHtml(svc.name || "", svc.description || ""))
      })
    } catch (e) {
      console.error("Failed to parse services JSON:", e)
    }
  }

  _applyFaqs(content) {
    try {
      const faqs = typeof content === "string" ? JSON.parse(content) : content
      if (!Array.isArray(faqs)) return

      const container = document.getElementById("faqs-container")
      container.innerHTML = ""
      faqs.forEach(faq => {
        container.insertAdjacentHTML("beforeend", this._faqEntryHtml(faq.question || "", faq.answer || ""))
      })
    } catch (e) {
      console.error("Failed to parse FAQs JSON:", e)
    }
  }

  _collectServiceNames() {
    const inputs = document.querySelectorAll("#services-container input[name*='[name]']")
    return Array.from(inputs).map(i => i.value).filter(v => v).join(", ")
  }

  _getFieldValue(id) {
    const el = document.getElementById(id)
    return el ? el.value : ""
  }

  _csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.content : ""
  }

  // ─── ADD / REMOVE ENTRIES ───────────────────────────────────

  addService() {
    const container = document.getElementById("services-container")
    container.insertAdjacentHTML("beforeend", this._serviceEntryHtml("", ""))
  }

  addFaq() {
    const container = document.getElementById("faqs-container")
    container.insertAdjacentHTML("beforeend", this._faqEntryHtml("", ""))
  }

  removeEntry(event) {
    const entry = event.currentTarget.closest(".service-entry, .faq-entry")
    if (entry) entry.remove()
  }

  // ─── HTML TEMPLATES ─────────────────────────────────────────

  _serviceEntryHtml(name, description) {
    return `
      <div class="service-entry flex gap-3 items-start p-4 bg-brand-card-alt dark:bg-slate-800 rounded-xl border border-brand-border dark:border-slate-700">
        <div class="flex-1 space-y-3">
          <input type="text" name="site_configuration[services_list][][name]" value="${this._escapeHtml(name)}" placeholder="Service name" class="w-full bg-white dark:bg-slate-900 border border-brand-border dark:border-slate-700 rounded-lg px-3 py-2 text-sm text-brand-text dark:text-slate-50 placeholder-brand-text-light dark:placeholder-slate-600 focus:border-brand-highlight focus:ring-1 focus:ring-brand-highlight/20 transition-colors">
          <textarea name="site_configuration[services_list][][description]" placeholder="Brief description of this service" rows="2" class="w-full bg-white dark:bg-slate-900 border border-brand-border dark:border-slate-700 rounded-lg px-3 py-2 text-sm text-brand-text dark:text-slate-50 placeholder-brand-text-light dark:placeholder-slate-600 focus:border-brand-highlight focus:ring-1 focus:ring-brand-highlight/20 transition-colors resize-none">${this._escapeHtml(description)}</textarea>
        </div>
        <button type="button" data-action="click->build-wizard#removeEntry" class="p-1.5 text-red-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-lg transition-colors">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
        </button>
      </div>`
  }

  _faqEntryHtml(question, answer) {
    return `
      <div class="faq-entry flex gap-3 items-start p-4 bg-brand-card-alt dark:bg-slate-800 rounded-xl border border-brand-border dark:border-slate-700">
        <div class="flex-1 space-y-3">
          <input type="text" name="site_configuration[faqs][][question]" value="${this._escapeHtml(question)}" placeholder="Question" class="w-full bg-white dark:bg-slate-900 border border-brand-border dark:border-slate-700 rounded-lg px-3 py-2 text-sm text-brand-text dark:text-slate-50 placeholder-brand-text-light dark:placeholder-slate-600 focus:border-brand-highlight focus:ring-1 focus:ring-brand-highlight/20 transition-colors">
          <textarea name="site_configuration[faqs][][answer]" placeholder="Answer" rows="2" class="w-full bg-white dark:bg-slate-900 border border-brand-border dark:border-slate-700 rounded-lg px-3 py-2 text-sm text-brand-text dark:text-slate-50 placeholder-brand-text-light dark:placeholder-slate-600 focus:border-brand-highlight focus:ring-1 focus:ring-brand-highlight/20 transition-colors resize-none">${this._escapeHtml(answer)}</textarea>
        </div>
        <button type="button" data-action="click->build-wizard#removeEntry" class="p-1.5 text-red-400 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded-lg transition-colors">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
        </button>
      </div>`
  }

  _escapeHtml(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }
}
