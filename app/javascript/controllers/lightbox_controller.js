import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]
  static values = { index: { type: Number, default: -1 } }

  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
  }

  open(event) {
    event.preventDefault()
    const idx = this.itemTargets.indexOf(event.currentTarget)
    this.indexValue = idx
    this.show()
  }

  show() {
    const item = this.itemTargets[this.indexValue]
    const url = item.dataset.lightboxUrl
    const total = this.itemTargets.length
    const current = this.indexValue + 1

    this.overlay = document.createElement("div")
    this.overlay.style.cssText = "position:fixed;inset:0;z-index:9999;display:flex;align-items:center;justify-content:center;background:rgba(15,27,45,0.6);backdrop-filter:blur(8px);-webkit-backdrop-filter:blur(8px);cursor:zoom-out;"

    this.overlay.innerHTML = `
      <button style="position:absolute;top:1.5rem;right:1.5rem;width:44px;height:44px;border-radius:50%;background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.15);color:rgba(255,255,255,0.8);font-size:1.25rem;display:flex;align-items:center;justify-content:center;cursor:pointer;transition:all 0.2s;z-index:10;" onmouseover="this.style.background='rgba(255,255,255,0.2)';this.style.color='white'" onmouseout="this.style.background='rgba(255,255,255,0.1)';this.style.color='rgba(255,255,255,0.8)'" data-action="click->lightbox#close">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>
      ${total > 1 ? `
        <button style="position:absolute;left:1.5rem;top:50%;transform:translateY(-50%);width:48px;height:48px;border-radius:50%;background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.15);color:rgba(255,255,255,0.8);font-size:1.25rem;display:flex;align-items:center;justify-content:center;cursor:pointer;transition:all 0.2s;z-index:10;" onmouseover="this.style.background='rgba(255,255,255,0.2)';this.style.color='white'" onmouseout="this.style.background='rgba(255,255,255,0.1)';this.style.color='rgba(255,255,255,0.8)'" data-action="click->lightbox#prev">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
        </button>
        <button style="position:absolute;right:1.5rem;top:50%;transform:translateY(-50%);width:48px;height:48px;border-radius:50%;background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.15);color:rgba(255,255,255,0.8);font-size:1.25rem;display:flex;align-items:center;justify-content:center;cursor:pointer;transition:all 0.2s;z-index:10;" onmouseover="this.style.background='rgba(255,255,255,0.2)';this.style.color='white'" onmouseout="this.style.background='rgba(255,255,255,0.1)';this.style.color='rgba(255,255,255,0.8)'" data-action="click->lightbox#next">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
        </button>
      ` : ""}
      <div style="position:absolute;bottom:1.5rem;left:50%;transform:translateX(-50%);">
        <span style="color:rgba(255,255,255,0.7);font-size:0.875rem;font-weight:500;letter-spacing:0.05em;">${current} of ${total}</span>
      </div>
      <img src="${url}" style="max-height:85vh;max-width:85vw;object-fit:contain;border-radius:0.75rem;box-shadow:0 25px 50px -12px rgba(0,0,0,0.5);" alt="">
    `

    this.overlay.addEventListener("click", (e) => {
      if (e.target === this.overlay) this.close()
    })

    document.body.appendChild(this.overlay)
    document.body.style.overflow = "hidden"
    document.addEventListener("keydown", this.handleKeydown)
  }

  close() {
    if (this.overlay) {
      this.overlay.remove()
      this.overlay = null
      document.body.style.overflow = ""
      document.removeEventListener("keydown", this.handleKeydown)
    }
  }

  next(event) {
    if (event) event.stopPropagation()
    this.close()
    this.indexValue = (this.indexValue + 1) % this.itemTargets.length
    this.show()
  }

  prev(event) {
    if (event) event.stopPropagation()
    this.close()
    this.indexValue = (this.indexValue - 1 + this.itemTargets.length) % this.itemTargets.length
    this.show()
  }

  handleKeydown(event) {
    if (event.key === "Escape") this.close()
    if (event.key === "ArrowRight") this.next()
    if (event.key === "ArrowLeft") this.prev()
  }

  disconnect() {
    this.close()
  }
}
