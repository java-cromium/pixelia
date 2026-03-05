import { Controller } from "@hotwired/stimulus"

// Auto-dismiss flash notifications after a delay
// Usage: <div data-controller="notification" data-notification-delay-value="5000">
export default class extends Controller {
  static values = { delay: { type: Number, default: 5000 } }

  connect() {
    this.element.classList.add("transition-all", "duration-300")
    this.timeout = setTimeout(() => this.dismiss(), this.delayValue)
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.classList.add("opacity-0", "translate-y-[-10px]")
    setTimeout(() => this.element.remove(), 300)
  }
}
