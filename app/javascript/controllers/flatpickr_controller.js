import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  static values = {
    altFormat: { type: String, default: "F j, Y" },
    minDate: String,
    maxDate: String,
    defaultDate: String
  }

  connect() {
    this.picker = flatpickr(this.element, {
      altInput: true,
      altInputClass: this.element.className + " ",
      altFormat: this.altFormatValue,
      dateFormat: "Y-m-d",
      allowInput: true,
      minDate: this.hasMinDateValue ? this.minDateValue : undefined,
      maxDate: this.hasMaxDateValue ? this.maxDateValue : undefined,
      defaultDate: this.hasDefaultDateValue ? this.defaultDateValue : undefined,
      onChange: (_dates, dateStr) => {
        this.element.value = dateStr
        this.element.dispatchEvent(new Event("change", { bubbles: true }))
      }
    })
  }

  disconnect() {
    if (this.picker) {
      this.picker.destroy()
      this.picker = null
    }
  }
}
