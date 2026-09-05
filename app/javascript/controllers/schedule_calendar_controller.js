import { Controller } from "@hotwired/stimulus"

const PALETTE = [
  "#3B82F6", "#10B981", "#F59E0B", "#8B5CF6",
  "#EC4899", "#06B6D4", "#F97316", "#6366F1",
  "#14B8A6", "#EF4444"
]

const DAY_NAMES = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
const COLS = 7
const MS_PER_DAY = 86400000

export default class extends Controller {
  static targets = ["grid", "dateLabel", "weekTab", "eightWeekTab", "completedToggle", "unscheduledPanel", "projectKey"]
  static values = { projects: Array, unscheduled: Array }

  connect() {
    this.view = "eightWeek"
    this.showCompleted = false
    this.anchorDate = this.startOfWeek(new Date())
    this.render()
  }

  prev() {
    const days = this.view === "week" ? 7 : 56
    this.anchorDate = this.addDays(this.anchorDate, -days)
    this.render()
  }

  next() {
    const days = this.view === "week" ? 7 : 56
    this.anchorDate = this.addDays(this.anchorDate, days)
    this.render()
  }

  today() {
    this.anchorDate = this.startOfWeek(new Date())
    this.render()
  }

  switchToWeek() {
    this.view = "week"
    this.render()
  }

  switchToEightWeek() {
    this.view = "eightWeek"
    this.render()
  }

  toggleCompleted() {
    this.showCompleted = this.completedToggleTarget.checked
    this.render()
  }

  render() {
    this.updateTabs()
    this.updateDateLabel()
    if (this.view === "week") {
      this.renderWeekView()
    } else {
      this.renderEightWeekView()
    }
    this.renderProjectKey()
    this.injectHighlightCSS()
  }

  updateTabs() {
    const active = "bg-white text-gray-900 shadow-sm"
    const inactive = "text-gray-500 hover:text-gray-700"
    this.weekTabTarget.className = `px-3 py-1.5 text-sm font-medium rounded-md transition ${this.view === "week" ? active : inactive}`
    this.eightWeekTabTarget.className = `px-3 py-1.5 text-sm font-medium rounded-md transition ${this.view === "eightWeek" ? active : inactive}`
  }

  updateDateLabel() {
    if (this.view === "week") {
      const end = this.addDays(this.anchorDate, 6)
      const opts = { month: "short", day: "numeric" }
      const startStr = this.anchorDate.toLocaleDateString("en-US", opts)
      const endStr = end.toLocaleDateString("en-US", this.anchorDate.getMonth() === end.getMonth() ? { day: "numeric" } : opts)
      this.dateLabelTarget.textContent = `${startStr} – ${endStr}, ${this.anchorDate.getFullYear()}`
    } else {
      const end = this.addDays(this.anchorDate, 55)
      const opts = { month: "short", day: "numeric" }
      this.dateLabelTarget.textContent = `${this.anchorDate.toLocaleDateString("en-US", opts)} – ${end.toLocaleDateString("en-US", opts)}, ${end.getFullYear()}`
    }
  }

  get filteredProjects() {
    return this.projectsValue.filter(p => {
      if (!this.showCompleted && (p.status === "complete" || p.status === "paid")) return false
      return true
    })
  }

  isSunday(date) {
    return date.getDay() === 0
  }

  // --- WEEK VIEW ---

  renderWeekView() {
    const days = []
    for (let i = 0; i < COLS; i++) {
      days.push(this.addDays(this.anchorDate, i))
    }

    const todayStr = this.toISO(new Date())
    const projects = this.projectsInRange(days[0], days[COLS - 1])
    const lanes = this.assignLanes(projects, days)
    const laneCount = Math.max(lanes.maxLane + 1, 1)
    const barHeight = 36
    const barGap = 4
    const gridHeight = laneCount * (barHeight + barGap) + barGap

    let html = `<div class="overflow-x-auto">`

    // Header row
    html += `<div class="grid border-b border-gray-200" style="grid-template-columns: repeat(${COLS}, minmax(0, 1fr))">`
    for (const day of days) {
      const iso = this.toISO(day)
      const isToday = iso === todayStr
      const isSun = this.isSunday(day)
      const dow = day.toLocaleDateString("en-US", { weekday: "short" })
      const dateNum = day.getDate()
      const bg = isToday ? "bg-accent/10" : isSun ? "bg-gray-100" : ""
      html += `<div class="px-3 py-2 text-center border-r border-gray-100 last:border-r-0 ${bg}">
        <div class="text-xs font-medium ${isToday ? "text-accent" : isSun ? "text-gray-400" : "text-gray-500"}">${dow}</div>
        <div class="text-sm font-semibold ${isToday ? "text-accent" : isSun ? "text-gray-400" : "text-gray-900"}">${dateNum}</div>
      </div>`
    }
    html += `</div>`

    // Body
    html += `<div class="relative" style="height: ${gridHeight}px">`

    // Column backgrounds
    for (let i = 0; i < COLS; i++) {
      const iso = this.toISO(days[i])
      const isToday = iso === todayStr
      const isSun = this.isSunday(days[i])
      const bg = isToday ? "bg-accent/5" : isSun ? "bg-gray-50" : ""
      html += `<div class="absolute top-0 bottom-0 border-r border-gray-50 ${bg}" style="left: ${(i / COLS) * 100}%; width: ${100 / COLS}%"></div>`
    }

    // Project bars
    for (const item of lanes.items) {
      const p = item.project
      const startCol = this.dayIndex(days, item.startInRange)
      const endCol = this.dayIndex(days, item.endInRange)
      if (startCol === -1 || endCol === -1) continue

      const left = (startCol / COLS) * 100
      const width = ((endCol - startCol + 1) / COLS) * 100
      const top = barGap + item.lane * (barHeight + barGap)
      const color = this.colorFor(p.id)
      const statusClass = this.statusOverlay(p.status)

      const label = p.customer_name
        ? `${this.truncateLabel(p.title, 50)} (${p.customer_name})`
        : this.truncateLabel(p.title)

      html += `<a href="${p.url}" class="proj proj-${p.id} absolute flex items-center rounded-md px-2 overflow-hidden hover:ring-2 hover:ring-offset-1 hover:ring-gray-400 transition group ${statusClass}" style="left: ${left}%; width: ${width}%; top: ${top}px; height: ${barHeight}px; background-color: ${color}">
        <span class="text-white text-xs font-medium truncate drop-shadow-sm">${this.escapeHtml(label)}</span>
      </a>`
    }

    if (lanes.items.length === 0) {
      html += `<div class="absolute inset-0 flex items-center justify-center text-sm text-gray-400">No projects scheduled this week</div>`
    }

    html += `</div></div>`

    this.gridTarget.innerHTML = html
  }

  // --- 8-WEEK VIEW ---

  renderEightWeekView() {
    const todayStr = this.toISO(new Date())
    const weeks = []
    for (let w = 0; w < 8; w++) {
      const weekStart = this.addDays(this.anchorDate, w * 7)
      const days = []
      for (let d = 0; d < COLS; d++) {
        days.push(this.addDays(weekStart, d))
      }
      weeks.push(days)
    }

    const barHeight = 6
    const cellMinHeight = 32

    let html = `<div class="overflow-x-auto">`

    // Header
    html += `<div class="grid border-b border-gray-200" style="grid-template-columns: repeat(${COLS}, minmax(0, 1fr))">`
    for (let i = 0; i < COLS; i++) {
      const isSun = i === 6
      html += `<div class="px-2 py-1.5 text-center text-xs font-medium ${isSun ? "text-gray-400" : "text-gray-500"} border-r border-gray-100 last:border-r-0">${DAY_NAMES[i]}</div>`
    }
    html += `</div>`

    // Weeks
    for (const days of weeks) {
      const weekProjects = this.projectsInRange(days[0], days[COLS - 1])
      const lanes = this.assignLanes(weekProjects, days)
      const laneCount = Math.max(lanes.maxLane + 1, 0)
      const rowHeight = Math.max(cellMinHeight, laneCount * (barHeight + 2) + 8)
      const monthDay = days[0].toLocaleDateString("en-US", { month: "short", day: "numeric" })

      html += `<div class="relative border-b border-gray-100" style="height: ${rowHeight}px">`

      // Day columns with month-alternating shading
      for (let i = 0; i < COLS; i++) {
        const iso = this.toISO(days[i])
        const isToday = iso === todayStr
        const isSun = this.isSunday(days[i])
        const month = days[i].getMonth()
        const monthShade = month % 2 === 0 ? "bg-white" : "bg-gray-100"
        const bg = isToday ? "bg-accent/10" : isSun ? (month % 2 === 0 ? "bg-gray-50" : "bg-gray-200/60") : monthShade

        html += `<div class="absolute top-0 bottom-0 border-r border-gray-50 ${bg}" style="left: ${(i / COLS) * 100}%; width: ${100 / COLS}%">
          <span class="text-[10px] ${isToday ? "text-accent font-semibold" : "text-gray-400"} px-1">${i === 0 ? monthDay : days[i].getDate()}</span>
        </div>`
      }

      // Thin bars
      for (const item of lanes.items) {
        const p = item.project
        const startCol = this.dayIndex(days, item.startInRange)
        const endCol = this.dayIndex(days, item.endInRange)
        if (startCol === -1 || endCol === -1) continue

        const left = (startCol / COLS) * 100
        const width = ((endCol - startCol + 1) / COLS) * 100
        const top = 14 + item.lane * (barHeight + 2)
        const color = this.colorFor(p.id)
        const statusClass = this.statusOverlay(p.status)

        const tip = p.customer_name ? `${p.title} (${p.customer_name})` : p.title
        html += `<a href="${p.url}" class="proj proj-${p.id} absolute rounded-sm hover:ring-1 hover:ring-gray-400 transition ${statusClass}" style="left: calc(${left}% + 2px); width: calc(${width}% - 4px); top: ${top}px; height: ${barHeight}px; background-color: ${color}" title="${this.escapeHtml(tip)}"></a>`
      }

      html += `</div>`
    }

    html += `</div>`
    this.gridTarget.innerHTML = html
  }

  // --- PROJECT KEY ---

  renderProjectKey() {
    if (!this.hasProjectKeyTarget) return

    const visible = this.visibleProjects()
    if (visible.length === 0) {
      this.projectKeyTarget.innerHTML = ""
      return
    }

    const seen = new Set()
    const unique = visible.filter(p => {
      if (seen.has(p.id)) return false
      seen.add(p.id)
      return true
    })

    let html = `<div class="flex flex-wrap gap-x-4 gap-y-1.5 mt-4 px-1">`
    for (const p of unique) {
      const color = this.colorFor(p.id)
      const label = p.customer_name
        ? `${this.truncateLabel(p.title, 50)} (${p.customer_name})`
        : this.truncateLabel(p.title)
      html += `<a href="${p.url}" class="proj proj-key proj-${p.id} inline-flex items-center gap-1.5 px-1.5 py-0.5 rounded text-xs text-gray-700 hover:text-gray-900" style="--proj-color: ${color}">
        <span class="w-2.5 h-2.5 rounded-full shrink-0" style="background-color: ${color}"></span>
        <span>${this.escapeHtml(label)}</span>
      </a>`
    }
    html += `</div>`
    this.projectKeyTarget.innerHTML = html
  }

  injectHighlightCSS() {
    const id = "sched-hl-css"
    let style = document.getElementById(id)
    if (!style) {
      style = document.createElement("style")
      style.id = id
      document.head.appendChild(style)
    }

    const sel = "[data-controller='schedule-calendar']"
    const ids = [...new Set(this.visibleProjects().map(p => p.id))]

    let css = `${sel} .proj { transition: opacity 0.2s ease, filter 0.2s ease, background-color 0.2s ease; }\n`
    for (const pid of ids) {
      css += `${sel}:has(.proj-${pid}:hover) .proj:not(.proj-${pid}) { opacity: 0.15; }\n`
      css += `${sel}:has(.proj-${pid}:hover) .proj-key.proj-${pid} { background-color: color-mix(in srgb, var(--proj-color) 20%, transparent); font-weight: 600; }\n`
    }
    style.textContent = css
  }

  visibleProjects() {
    if (this.view === "week") {
      const start = this.anchorDate
      const end = this.addDays(this.anchorDate, COLS - 1)
      return this.projectsInRange(start, end)
    } else {
      const start = this.anchorDate
      const end = this.addDays(this.anchorDate, 55)
      return this.projectsInRange(start, end)
    }
  }

  // --- LANE ASSIGNMENT ---

  assignLanes(projects, days) {
    const rangeStart = days[0]
    const rangeEnd = days[days.length - 1]
    const items = []

    for (const p of projects) {
      const pStart = new Date(p.start_date + "T00:00:00")
      const pEnd = new Date(p.end_date + "T00:00:00")
      const startInRange = pStart < rangeStart ? rangeStart : pStart
      const endInRange = pEnd > rangeEnd ? rangeEnd : pEnd

      if (startInRange > rangeEnd || endInRange < rangeStart) continue

      items.push({ project: p, startInRange, endInRange, lane: 0 })
    }

    items.sort((a, b) => a.startInRange - b.startInRange || (b.endInRange - b.startInRange) - (a.endInRange - a.startInRange))

    const laneEnds = []
    for (const item of items) {
      let placed = false
      for (let lane = 0; lane < laneEnds.length; lane++) {
        if (item.startInRange > laneEnds[lane]) {
          item.lane = lane
          laneEnds[lane] = item.endInRange
          placed = true
          break
        }
      }
      if (!placed) {
        item.lane = laneEnds.length
        laneEnds.push(item.endInRange)
      }
    }

    return { items, maxLane: Math.max(0, laneEnds.length - 1) }
  }

  projectsInRange(rangeStart, rangeEnd) {
    const startStr = this.toISO(rangeStart)
    const endStr = this.toISO(rangeEnd)
    return this.filteredProjects.filter(p => {
      return p.start_date <= endStr && p.end_date >= startStr
    })
  }

  // --- HELPERS ---

  dayIndex(days, date) {
    const iso = this.toISO(date)
    return days.findIndex(d => this.toISO(d) === iso)
  }

  startOfWeek(date) {
    const d = new Date(date.getFullYear(), date.getMonth(), date.getDate())
    const day = d.getDay()
    const diff = day === 0 ? -6 : 1 - day
    d.setDate(d.getDate() + diff)
    return d
  }

  addDays(date, n) {
    return new Date(date.getTime() + n * MS_PER_DAY)
  }

  toISO(date) {
    const y = date.getFullYear()
    const m = String(date.getMonth() + 1).padStart(2, "0")
    const d = String(date.getDate()).padStart(2, "0")
    return `${y}-${m}-${d}`
  }

  colorFor(id) {
    return PALETTE[id % PALETTE.length]
  }

  statusOverlay(status) {
    if (status === "blocked") return "opacity-75 bg-stripes"
    if (status === "complete" || status === "paid") return "opacity-50"
    return ""
  }

  truncateLabel(str, max = 50) {
    return str.length > max ? str.slice(0, max - 1) + "…" : str
  }

  escapeHtml(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }
}
