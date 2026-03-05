import { Controller } from "@hotwired/stimulus"

// Toggle dropdown menus
// Usage: <div data-controller="dropdown">
//   <button data-action="click->dropdown#toggle">Menu</button>
//   <div data-dropdown-target="menu" class="hidden">...</div>
// </div>
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.clickOutside = this.clickOutside.bind(this)
    document.addEventListener("click", this.clickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.clickOutside)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }
}
