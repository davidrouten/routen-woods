import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "phone", "customerArea", "customerId"]
  static values = { currentName: String, currentId: Number }

  connect() {
    this.timeout = null
    this.searchTimeout = null
    this.activeIndex = -1
    if (this.currentIdValue && this.currentNameValue) {
      this.showLinked(this.currentNameValue)
    } else {
      this.showSearchField()
    }
  }

  showSearchField() {
    this.customerAreaTarget.innerHTML = `
      <label class="block text-sm font-semibold text-gray-700 mb-1.5">Customer</label>
      <div class="relative">
        <input type="text" placeholder="Search customers by name, email, or phone..."
               class="input-admin w-full"
               data-action="input->customer-suggest#search keydown->customer-suggest#onKeydown focus->customer-suggest#onFocus" />
        <div class="absolute z-10 left-0 right-0 mt-1 bg-white border border-gray-200 rounded-lg shadow-lg max-h-48 overflow-y-auto hidden"
             data-role="results"></div>
      </div>
      <p class="text-xs text-gray-400 mt-1">If no customer is linked, one will be automatically created on save.</p>
    `
    this.customerAreaTarget.classList.remove("hidden")
  }

  showLinked(name) {
    this.customerAreaTarget.innerHTML = `
      <div class="flex items-center justify-between gap-3 px-3 py-2 bg-emerald-50 border border-emerald-200 rounded-lg text-sm">
        <div>
          <span class="text-emerald-600 text-xs font-medium">Customer</span>
          <span class="font-semibold text-emerald-800 ml-1">${this.escapeHtml(name)}</span>
        </div>
        <div class="flex items-center gap-2">
          <a href="/admin/customers/${this.customerIdTarget.value}" target="_blank" class="text-xs text-emerald-600 hover:text-emerald-800 underline">View</a>
          <button type="button" class="text-xs text-red-500 hover:text-red-700 underline" data-action="customer-suggest#unlinkCustomer">Remove</button>
        </div>
      </div>
    `
    this.customerAreaTarget.classList.remove("hidden")
  }

  search(event) {
    clearTimeout(this.searchTimeout)
    const query = event.target.value.trim()
    const resultsEl = this.customerAreaTarget.querySelector('[data-role="results"]')

    if (query.length < 2) {
      resultsEl.classList.add("hidden")
      this.activeIndex = -1
      return
    }

    this.searchTimeout = setTimeout(() => this.fetchSearch(query), 200)
  }

  async fetchSearch(query) {
    const resultsEl = this.customerAreaTarget.querySelector('[data-role="results"]')
    try {
      const response = await fetch(`/admin/customers/suggest?q=${encodeURIComponent(query)}`, {
        headers: { "Accept": "application/json" }
      })
      const matches = await response.json()
      this.activeIndex = -1

      if (matches.length === 0) {
        resultsEl.innerHTML = `<div class="px-3 py-2 text-sm text-gray-400">No customers found</div>`
      } else {
        resultsEl.innerHTML = matches.map((c, i) => `
          <div class="px-3 py-2 hover:bg-gray-50 cursor-pointer text-sm transition search-result"
               data-action="click->customer-suggest#selectCustomer"
               data-customer-id="${c.id}"
               data-customer-name="${this.escapeHtml(c.name)}"
               data-index="${i}">
            <p class="font-medium text-gray-900">${this.escapeHtml(c.name)}</p>
            <p class="text-xs text-gray-500">${[c.email, c.phone].filter(Boolean).join(" · ")}</p>
          </div>
        `).join("")
      }
      resultsEl.classList.remove("hidden")
    } catch {
      resultsEl.classList.add("hidden")
    }
  }

  onFocus(event) {
    if (event.target.value.trim().length >= 2) {
      const resultsEl = this.customerAreaTarget.querySelector('[data-role="results"]')
      if (resultsEl && resultsEl.innerHTML) resultsEl.classList.remove("hidden")
    }
  }

  onKeydown(event) {
    const resultsEl = this.customerAreaTarget.querySelector('[data-role="results"]')
    const items = resultsEl ? resultsEl.querySelectorAll(".search-result") : []

    if (event.key === "ArrowDown") {
      event.preventDefault()
      this.activeIndex = Math.min(this.activeIndex + 1, items.length - 1)
      this.highlightActive(items)
    } else if (event.key === "ArrowUp") {
      event.preventDefault()
      this.activeIndex = Math.max(this.activeIndex - 1, -1)
      this.highlightActive(items)
    } else if (event.key === "Enter" && this.activeIndex >= 0 && items[this.activeIndex]) {
      event.preventDefault()
      items[this.activeIndex].click()
    } else if (event.key === "Escape") {
      resultsEl.classList.add("hidden")
      this.activeIndex = -1
    }
  }

  highlightActive(items) {
    items.forEach((item, i) => {
      item.classList.toggle("bg-gray-100", i === this.activeIndex)
    })
  }

  selectCustomer(event) {
    const el = event.currentTarget
    const id = el.dataset.customerId
    const name = el.dataset.customerName
    this.customerIdTarget.value = id
    this.showLinked(name)
  }

  // Auto-suggest on blur of email/phone fields
  lookup() {
    clearTimeout(this.timeout)
    if (this.customerIdTarget.value) return
    if (this.skipNextBlur) { this.skipNextBlur = false; return }
    this.timeout = setTimeout(() => this.fetchAutoSuggest(), 300)
  }

  async fetchAutoSuggest() {
    const email = this.hasEmailTarget ? this.emailTarget.value.trim() : ""
    const phone = this.hasPhoneTarget ? this.phoneTarget.value.trim() : ""

    if (!email && !phone) return

    const params = new URLSearchParams()
    if (email) params.set("email", email)
    if (phone) params.set("phone", phone)

    try {
      const response = await fetch(`/admin/customers/suggest?${params}`, {
        headers: { "Accept": "application/json" }
      })
      const matches = await response.json()

      if (matches.length > 0 && !this.customerIdTarget.value) {
        this.customerIdTarget.value = matches[0].id
        this.showLinked(matches[0].name)
      }
    } catch { /* ignore */ }
  }

  unlinkCustomer() {
    this.customerIdTarget.value = ""
    this.currentIdValue = 0
    this.currentNameValue = ""
    this.skipNextBlur = true
    this.showSearchField()
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text || ""
    return div.innerHTML
  }
}
