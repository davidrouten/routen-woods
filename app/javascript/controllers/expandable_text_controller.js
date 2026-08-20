import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["text", "toggle"]

  connect() {
    requestAnimationFrame(() => {
      if (this.textTarget.scrollHeight <= this.textTarget.offsetHeight) {
        this.toggleTarget.hidden = true
      }
    })
  }

  toggle() {
    const clamped = this.textTarget.classList.toggle("line-clamp-5")
    this.toggleTarget.textContent = clamped ? "Read more" : "Read less"
    this.toggleTarget.setAttribute("aria-expanded", !clamped)
  }
}
