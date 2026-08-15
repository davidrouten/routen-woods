import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "field"]

  toggle() {
    this.fieldTarget.classList.toggle("hidden", !this.checkboxTarget.checked)
    if (!this.checkboxTarget.checked) {
      this.fieldTarget.querySelector("input").value = ""
    }
  }
}
