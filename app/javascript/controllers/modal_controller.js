import { Controller } from "@hotwired/stimulus"

// Global modal controller — attach to <body> so all actions bubble up.

export default class extends Controller {
  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
  }

  get isOpen() {
    return !!this.overlay
  }

  get focusableButtons() {
    if (!this.overlay) return []
    return [...this.overlay.querySelectorAll("button, input[type='submit'], [tabindex='0']")]
  }

  openConfirm(event) {
    if (this.isOpen) return
    event.preventDefault()
    const el = event.currentTarget
    const title = el.dataset.confirmTitle
    const message = el.dataset.confirmMessage
    const confirmText = el.dataset.confirmText
    const confirmClassType = el.dataset.confirmClass
    const formSelector = el.dataset.confirmForm
    const confirmClass = confirmClassType === "danger"
      ? "bg-red-600 hover:bg-red-700 text-white"
      : "bg-[#d4a338] hover:bg-[#b8860b] text-[#0f1b2d]"

    this.pendingFormSelector = formSelector || null

    this.render(`
      <div class="text-center sm:text-left">
        <h3 class="text-lg font-bold text-gray-900 mb-2">${title || "Confirm"}</h3>
        <p class="text-gray-600 text-sm">${message || "Are you sure?"}</p>
      </div>
      <div class="flex justify-end gap-3 mt-6">
        <button data-role="modal-cancel" class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg transition cursor-pointer focus:ring-2 focus:ring-[#0f1b2d] focus:outline-none">Cancel</button>
        <button data-role="modal-confirm" class="px-4 py-2 text-sm font-bold rounded-lg transition cursor-pointer focus:ring-2 focus:ring-[#0f1b2d] focus:outline-none ${confirmClass}">${confirmText || "Confirm"}</button>
      </div>
    `)
  }

  openContent(event) {
    if (this.isOpen) return
    event.preventDefault()
    const targetSelector = event.currentTarget.dataset.modalTarget
    const template = document.querySelector(targetSelector)
    if (template) {
      this.pendingFormSelector = null
      this.render(template.innerHTML)
    }
  }

  render(bodyHTML) {
    this.overlay = document.createElement("div")
    this.overlay.style.cssText = "position:fixed;inset:0;z-index:9999;display:flex;align-items:center;justify-content:center;background:rgba(15,27,45,0.5);backdrop-filter:blur(4px);-webkit-backdrop-filter:blur(4px);"

    this.overlay.innerHTML = `
      <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden transform" style="animation: modalIn 0.2s ease-out;">
        <div class="h-1 bg-gradient-to-r from-[#d4a338] to-[#b8860b]"></div>
        <div class="p-6">
          ${bodyHTML}
        </div>
      </div>
    `

    // Backdrop click
    this.overlay.addEventListener("click", (e) => {
      if (e.target === this.overlay) this.close()
    })

    // Wire up cancel buttons
    this.overlay.querySelectorAll("[data-role='modal-cancel']").forEach((btn) => {
      btn.addEventListener("click", () => this.close())
    })

    // Wire up confirm buttons
    this.overlay.querySelectorAll("[data-role='modal-confirm']").forEach((btn) => {
      btn.addEventListener("click", () => this.confirmAndClose())
    })

    if (!document.getElementById("modal-keyframes")) {
      const style = document.createElement("style")
      style.id = "modal-keyframes"
      style.textContent = `
        @keyframes modalIn {
          from { opacity: 0; transform: scale(0.95) translateY(10px); }
          to { opacity: 1; transform: scale(1) translateY(0); }
        }
      `
      document.head.appendChild(style)
    }

    this.element.appendChild(this.overlay)
    document.body.style.overflow = "hidden"
    document.addEventListener("keydown", this.handleKeydown, true)

    // Focus the action button (last one)
    requestAnimationFrame(() => {
      const buttons = this.focusableButtons
      if (buttons.length) buttons[buttons.length - 1].focus()
    })
  }

  confirmAndClose() {
    const formSelector = this.pendingFormSelector
    this.close()
    if (formSelector) {
      const form = document.querySelector(formSelector)
      if (form) form.requestSubmit()
    }
  }

  close() {
    if (this.overlay) {
      this.overlay.remove()
      this.overlay = null
      this.pendingFormSelector = null
      document.body.style.overflow = ""
      document.removeEventListener("keydown", this.handleKeydown, true)
    }
  }

  handleKeydown(event) {
    if (!this.isOpen) return

    if (event.key === "Escape") {
      event.preventDefault()
      this.close()
      return
    }

    // Arrow keys and Tab navigate between focusable buttons
    if (["ArrowRight", "ArrowLeft", "Tab"].includes(event.key)) {
      event.preventDefault()
      const buttons = this.focusableButtons
      if (!buttons.length) return
      const currentIdx = buttons.indexOf(document.activeElement)
      let nextIdx

      if (event.key === "ArrowRight" || (event.key === "Tab" && !event.shiftKey)) {
        nextIdx = currentIdx < buttons.length - 1 ? currentIdx + 1 : 0
      } else {
        nextIdx = currentIdx > 0 ? currentIdx - 1 : buttons.length - 1
      }

      buttons[nextIdx].focus()
      return
    }

    // Enter activates the focused button
    if (event.key === "Enter") {
      event.preventDefault()
      const active = document.activeElement
      if (active && this.overlay.contains(active)) {
        active.click()
      }
    }
  }

  disconnect() {
    this.close()
  }
}
