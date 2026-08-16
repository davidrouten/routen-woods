import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "menu"]

  connect() {
    this.updateExpanded = this.updateExpanded.bind(this)
    this.element.addEventListener("mouseenter", this.updateExpanded)
    this.element.addEventListener("mouseleave", this.updateExpanded)
    this.element.addEventListener("focusin", this.updateExpanded)
    this.element.addEventListener("focusout", this.updateExpanded)
  }

  disconnect() {
    this.element.removeEventListener("mouseenter", this.updateExpanded)
    this.element.removeEventListener("mouseleave", this.updateExpanded)
    this.element.removeEventListener("focusin", this.updateExpanded)
    this.element.removeEventListener("focusout", this.updateExpanded)
  }

  updateExpanded() {
    requestAnimationFrame(() => {
      const isOpen = this.element.matches(":hover") || this.element.contains(document.activeElement)
      this.buttonTarget.setAttribute("aria-expanded", isOpen)
    })
  }
}
