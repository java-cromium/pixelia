import { Controller } from "@hotwired/stimulus"

// Copy text to clipboard
// Usage: <button data-controller="clipboard" data-clipboard-text-value="some text"
//          data-action="click->clipboard#copy">Copy</button>
export default class extends Controller {
  static values = { text: String }

  async copy() {
    try {
      await navigator.clipboard.writeText(this.textValue)
      const original = this.element.innerHTML
      this.element.innerHTML = "Copied!"
      this.element.classList.add("text-green-600")
      setTimeout(() => {
        this.element.innerHTML = original
        this.element.classList.remove("text-green-600")
      }, 2000)
    } catch {
      // Fallback for older browsers
      const textarea = document.createElement("textarea")
      textarea.value = this.textValue
      document.body.appendChild(textarea)
      textarea.select()
      document.execCommand("copy")
      document.body.removeChild(textarea)
    }
  }
}
