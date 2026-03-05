import { Controller } from "@hotwired/stimulus"

// Filters table rows based on search input
// Usage: <div data-controller="search">
//   <input data-search-target="input" data-action="input->search#filter">
//   <table><tbody data-search-target="body">...</tbody></table>
// </div>
export default class extends Controller {
  static targets = ["input", "body"]

  filter() {
    const query = this.inputTarget.value.toLowerCase().trim()
    const rows = this.bodyTarget.querySelectorAll("tr")

    rows.forEach(row => {
      const text = row.textContent.toLowerCase()
      row.style.display = text.includes(query) ? "" : "none"
    })
  }

  clear() {
    this.inputTarget.value = ""
    this.filter()
    this.inputTarget.focus()
  }
}
