import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startDate", "duration", "workSaturdays", "endDate", "presetButtons"]

  connect() {
    this.calculate()
  }

  calculate() {
    const dateVal = this.startDateTarget.value
    const duration = parseFloat(this.durationTarget.value)
    const workSat = this.workSaturdaysTarget.checked

    if (!dateVal || !duration || duration <= 0) {
      this.endDateTarget.textContent = "Set a start date and duration"
      this.endDateTarget.classList.remove("text-green-700", "bg-green-50")
      return
    }

    const startDate = new Date(dateVal + "T00:00:00")
    const endDate = this.computeEnd(startDate, duration, workSat)
    const workDays = this.computeWorkDays(startDate, duration, workSat)

    let text = `${this.formatDate(startDate)}`
    if (endDate.getTime() !== startDate.getTime()) {
      text += ` - ${this.formatDate(endDate)}`
    }
    text += ` (${this.formatDuration(duration)}, ${workDays.length} work day${workDays.length === 1 ? '' : 's'})`

    this.endDateTarget.textContent = text
    this.endDateTarget.classList.add("text-green-700", "bg-green-50")
  }

  selectPreset(event) {
    event.preventDefault()
    const value = event.currentTarget.dataset.duration
    this.durationTarget.value = value
    this.highlightPreset(value)
    this.calculate()
  }

  highlightPreset(value) {
    this.presetButtonsTarget.querySelectorAll("button").forEach(btn => {
      if (btn.dataset.duration === value) {
        btn.classList.remove("bg-gray-100", "text-gray-700")
        btn.classList.add("bg-primary", "text-white")
      } else {
        btn.classList.remove("bg-primary", "text-white")
        btn.classList.add("bg-gray-100", "text-gray-700")
      }
    })
  }

  computeEnd(startDate, durationDays, workSat) {
    let current = new Date(startDate)
    const wholeDays = durationDays === Math.floor(durationDays)
      ? durationDays - 1
      : Math.floor(durationDays)

    for (let i = 0; i < wholeDays; i++) {
      current = this.nextWorkDay(current, workSat)
    }
    return current
  }

  computeWorkDays(startDate, durationDays, workSat) {
    const days = []
    let current = new Date(startDate)
    const total = Math.ceil(durationDays)

    days.push(new Date(current))
    for (let i = 1; i < total; i++) {
      current = this.nextWorkDay(current, workSat)
      days.push(new Date(current))
    }
    return days
  }

  nextWorkDay(date, workSat) {
    const next = new Date(date)
    do {
      next.setDate(next.getDate() + 1)
    } while (this.skipDay(next, workSat))
    return next
  }

  skipDay(date, workSat) {
    const day = date.getDay()
    if (day === 0) return true
    if (day === 6 && !workSat) return true
    return false
  }

  formatDate(date) {
    const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    return `${days[date.getDay()]}, ${months[date.getMonth()]} ${date.getDate()}`
  }

  formatDuration(days) {
    if (days === Math.floor(days)) {
      return `${days} day${days === 1 ? '' : 's'}`
    }
    return `${days} days`
  }
}
