import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    this.shown = sessionStorage.getItem("exitIntentShown") === "true"
    if (!this.shown) {
      document.addEventListener("mouseout", this.handleMouseOut)
    }
  }

  disconnect() {
    document.removeEventListener("mouseout", this.handleMouseOut)
  }

  handleMouseOut = (event) => {
    if (event.clientY <= 0 && !this.shown) {
      this.show()
    }
  }

  show() {
    this.shown = true
    sessionStorage.setItem("exitIntentShown", "true")
    this.modalTarget.classList.remove("hidden")
    document.removeEventListener("mouseout", this.handleMouseOut)
  }

  close() {
    this.modalTarget.classList.add("hidden")
  }
}
