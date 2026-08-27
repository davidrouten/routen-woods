import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "phone", "suggestion", "customerId"]

  connect() {
    this.timeout = null
  }

  lookup() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.fetchSuggestions(), 300)
  }

  async fetchSuggestions() {
    const email = this.emailTarget.value.trim()
    const phone = this.phoneTarget.value.trim()

    if (!email && !phone) {
      this.hideSuggestion()
      return
    }

    const params = new URLSearchParams()
    if (email) params.set("email", email)
    if (phone) params.set("phone", phone)

    try {
      const response = await fetch(`/admin/customers/suggest?${params}`, {
        headers: { "Accept": "application/json" }
      })
      const matches = await response.json()

      if (matches.length > 0) {
        this.showSuggestion(matches[0])
      } else {
        this.hideSuggestion()
      }
    } catch {
      this.hideSuggestion()
    }
  }

  showSuggestion(customer) {
    const details = [
      customer.lead_count > 0 ? `${customer.lead_count} lead${customer.lead_count === 1 ? '' : 's'}` : null,
      customer.project_count > 0 ? `${customer.project_count} project${customer.project_count === 1 ? '' : 's'}` : null
    ].filter(Boolean).join(", ")

    this.suggestionTarget.innerHTML = `
      <div class="flex items-center justify-between gap-3 px-3 py-2 bg-blue-50 border border-blue-200 rounded-lg text-sm">
        <div>
          <span class="font-medium text-blue-900">${this.escapeHtml(customer.name)}</span>
          ${details ? `<span class="text-blue-600">(${details})</span>` : ''}
        </div>
        <button type="button" class="px-2 py-1 bg-blue-600 text-white rounded text-xs font-medium hover:bg-blue-700 transition" data-action="customer-suggest#linkCustomer" data-customer-id="${customer.id}">
          Link
        </button>
      </div>
    `
    this.suggestionTarget.classList.remove("hidden")
  }

  hideSuggestion() {
    this.suggestionTarget.classList.add("hidden")
    this.suggestionTarget.innerHTML = ""
  }

  linkCustomer(event) {
    const customerId = event.currentTarget.dataset.customerId
    this.customerIdTarget.value = customerId

    this.suggestionTarget.innerHTML = `
      <div class="flex items-center justify-between gap-3 px-3 py-2 bg-emerald-50 border border-emerald-200 rounded-lg text-sm">
        <span class="font-medium text-emerald-800">Customer linked</span>
        <button type="button" class="text-xs text-emerald-600 hover:text-emerald-800 underline" data-action="customer-suggest#unlinkCustomer">Remove</button>
      </div>
    `
  }

  unlinkCustomer() {
    this.customerIdTarget.value = ""
    this.hideSuggestion()
    this.fetchSuggestions()
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
