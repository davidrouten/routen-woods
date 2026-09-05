import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["amount", "deposit"]
  static values = {
    balanceDue: Number,
    depositAmount: Number,
    hasDeposit: Boolean
  }

  fillBalance() {
    this.amountTarget.value = this.balanceDueValue
    this.amountTarget.focus()
  }

  toggleDeposit() {
    if (this.depositTarget.checked && !this.hasDepositValue && !this.amountTarget.value) {
      this.amountTarget.value = this.depositAmountValue
    }
  }
}
