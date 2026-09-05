import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template", "item", "destroy", "adjustmentContainer", "adjustmentTemplate", "paymentContainer", "paymentTemplate"]

  add() {
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.containerTarget.insertAdjacentHTML("beforeend", content)
  }

  addAdjustment() {
    const content = this.adjustmentTemplateTarget.innerHTML.replace(/NEW_ADJUSTMENT/g, new Date().getTime())
    this.adjustmentContainerTarget.insertAdjacentHTML("beforeend", content)
  }

  addPayment() {
    const content = this.paymentTemplateTarget.innerHTML.replace(/NEW_PAYMENT/g, new Date().getTime())
    this.paymentContainerTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    const item = event.target.closest("[data-nested-form-target='item']")
    const destroyField = item.querySelector("[data-nested-form-target='destroy']")
    const persisted = item.querySelector("input[type='hidden'][name$='[id]']")

    if (destroyField && persisted) {
      destroyField.value = "1"
      item.style.display = "none"
      item.querySelectorAll("[required]").forEach(input => input.removeAttribute("required"))
    } else {
      item.remove()
    }
  }
}
