import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            this.buttonTarget.classList.add("hidden")
          } else {
            this.buttonTarget.classList.remove("hidden")
          }
        })
      },
      { threshold: 0.1 }
    )

    const hero = document.querySelector("[data-hero]")
    const contactSection = document.getElementById("contact")

    if (hero) this.observer.observe(hero)
    if (contactSection) this.observer.observe(contactSection)
  }

  disconnect() {
    this.observer.disconnect()
  }
}
