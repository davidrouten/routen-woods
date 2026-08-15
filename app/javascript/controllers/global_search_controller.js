import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]

  connect() {
    this.timeout = null
    this.activeIndex = -1
    this.handleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.handleClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside)
  }

  search() {
    clearTimeout(this.timeout)
    const query = this.inputTarget.value.trim()

    if (query.length < 2) {
      this.resultsTarget.innerHTML = ""
      this.resultsTarget.classList.add("hidden")
      this.activeIndex = -1
      return
    }

    this.timeout = setTimeout(() => this.fetchResults(query), 200)
  }

  async fetchResults(query) {
    const response = await fetch(`/admin/search?q=${encodeURIComponent(query)}`, {
      headers: { "Accept": "application/json" }
    })
    const results = await response.json()
    this.activeIndex = -1
    this.renderResults(results)
  }

  renderResults(results) {
    if (results.length === 0) {
      this.resultsTarget.innerHTML = `<div class="px-4 py-3 text-sm text-gray-400">No results found</div>`
      this.resultsTarget.classList.remove("hidden")
      return
    }

    const statusColors = {
      incoming: "bg-blue-100 text-blue-700",
      contacted: "bg-yellow-100 text-yellow-700",
      scheduled: "bg-purple-100 text-purple-700",
      quoted: "bg-orange-100 text-orange-700",
      booked: "bg-green-100 text-green-700",
      completed: "bg-gray-100 text-gray-600",
      lost: "bg-red-100 text-red-700"
    }

    const html = results.map((r, i) => {
      const statusClass = statusColors[r.status] || "bg-gray-100 text-gray-600"
      const activeClass = i === this.activeIndex ? "bg-gray-100" : ""
      return `
        <a href="${r.url}" class="search-result flex items-center gap-3 px-4 py-2.5 hover:bg-gray-100 transition text-sm group ${activeClass}" data-index="${i}">
          <div class="w-7 h-7 rounded-lg bg-gray-100 group-hover:bg-accent/10 flex items-center justify-center text-gray-400 group-hover:text-accent flex-shrink-0">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
          </div>
          <div class="flex-1 min-w-0">
            <p class="font-medium text-gray-900 truncate">${this.escapeHtml(r.title)}</p>
            <p class="text-xs text-gray-400 truncate">${this.escapeHtml(r.subtitle)}</p>
          </div>
          <span class="text-[10px] font-medium px-1.5 py-0.5 rounded-full ${statusClass} capitalize flex-shrink-0">${r.status}</span>
        </a>
      `
    }).join("")

    this.resultsTarget.innerHTML = html
    this.resultsTarget.classList.remove("hidden")
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.resultsTarget.classList.add("hidden")
    }
  }

  onFocus() {
    if (this.inputTarget.value.trim().length >= 2) {
      this.resultsTarget.classList.remove("hidden")
    }
  }

  onKeydown(event) {
    const items = this.resultsTarget.querySelectorAll(".search-result")

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
      this.resultsTarget.classList.add("hidden")
      this.activeIndex = -1
      this.inputTarget.blur()
    }
  }

  highlightActive(items) {
    items.forEach((item, i) => {
      if (i === this.activeIndex) {
        item.classList.add("bg-gray-100")
        item.scrollIntoView({ block: "nearest" })
      } else {
        item.classList.remove("bg-gray-100")
      }
    })
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
