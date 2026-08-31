import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static classes = ["active", "inactive"]

  switch({ params: { panel } }) {
    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.tabsPanelParam === panel
      tab.className = tab.className.replace(/bg-\S+|text-\S+|hover:\S+|border\S*/g, "").trim()
      const classes = isActive ? this.activeClasses : this.inactiveClasses
      tab.classList.add(...classes)
    })

    this.panelTargets.forEach(p => {
      p.classList.toggle("hidden", p.dataset.tabsName !== panel)
    })
  }
}
