import { Controller } from "@hotwired/stimulus"

// Filters table rows by a select dropdown value against a data attribute
// Usage: <div data-controller="filter">
//   <select data-filter-target="select" data-action="change->filter#apply">
//   <table><tbody data-filter-target="body">...</tbody></table>
// </div>
// Each <tr> should have data-filter-value="some_value"
export default class extends Controller {
  static targets = ["select", "body"]

  apply() {
    const selected = this.selectTarget.value
    const rows = this.bodyTarget.querySelectorAll("tr")

    rows.forEach(row => {
      if (!selected || selected === "all") {
        row.style.display = ""
      } else {
        row.style.display = row.dataset.filterValue === selected ? "" : "none"
      }
    })
  }

  reset() {
    this.selectTarget.value = "all"
    this.apply()
  }
}
