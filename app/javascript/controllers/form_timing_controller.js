import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["completionField"]

  connect() {
    this.startTime = null
  }

  start() {
    if (!this.startTime) {
      this.startTime = Date.now()
    }
  }

  submit() {
    if (this.startTime && this.hasCompletionFieldTarget) {
      const seconds = (Date.now() - this.startTime) / 1000
      this.completionFieldTarget.value = seconds.toFixed(1)
    }
  }
}
