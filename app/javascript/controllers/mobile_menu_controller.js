import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
    const isOpen = !this.menuTarget.classList.contains("hidden")
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", isOpen)
    }
  }
}
