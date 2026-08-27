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
      complete: "bg-gray-100 text-gray-600",
      lost: "bg-red-100 text-red-700",
      in_progress: "bg-blue-100 text-blue-700",
      blocked: "bg-red-100 text-red-700",
      paid: "bg-green-100 text-green-700",
      draft: "bg-gray-100 text-gray-600",
      sent: "bg-yellow-100 text-yellow-700",
      partially_paid: "bg-orange-100 text-orange-700"
    }

    const icons = {
      Lead: `<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>`,
      Project: `<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>`,
      Invoice: `<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"/></svg>`,
      Customer: `<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/></svg>`
    }

    const html = results.map((r, i) => {
      const statusClass = statusColors[r.status] || "bg-gray-100 text-gray-600"
      const icon = icons[r.type] || icons.Lead
      const statusLabel = (r.status || "").replace("_", " ")
      const activeClass = i === this.activeIndex ? "bg-gray-100" : ""
      return `
        <a href="${r.url}" class="search-result flex items-center gap-3 px-4 py-2.5 hover:bg-gray-100 transition text-sm group ${activeClass}" data-index="${i}">
          <div class="w-7 h-7 rounded-lg bg-gray-100 group-hover:bg-accent/10 flex items-center justify-center text-gray-400 group-hover:text-accent flex-shrink-0">
            ${icon}
          </div>
          <div class="flex-1 min-w-0">
            <p class="font-medium text-gray-900 truncate">${this.escapeHtml(r.title)}</p>
            <p class="text-xs text-gray-400 truncate">${this.escapeHtml(r.subtitle)}</p>
          </div>
          <div class="flex flex-col items-end gap-0.5 flex-shrink-0">
            <span class="text-[10px] font-medium text-gray-300">${r.type}</span>
            <span class="text-[10px] font-medium px-1.5 py-0.5 rounded-full ${statusClass} capitalize">${statusLabel}</span>
          </div>
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
