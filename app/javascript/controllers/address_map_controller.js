import { Controller } from "@hotwired/stimulus"
import LeafletAdapter from "map_adapters/leaflet_adapter"

export default class extends Controller {
  static targets = ["map", "distance", "street", "city", "state", "zip", "fullAddress", "error"]
  static values = {
    businessLat: Number,
    businessLng: Number,
    businessLabel: String
  }

  connect() {
    this.timeout = null
    this.adapter = new LeafletAdapter(this.mapTarget)
    this.geocodeFromExisting()
  }

  disconnect() {
    this.adapter.destroy()
  }

  geocodeFromExisting() {
    const address = this.buildAddress()
    if (address.length >= 3) {
      this.geocode(address)
    }
  }

  onAddressChange() {
    clearTimeout(this.timeout)
    const address = this.buildAddress()

    if (address.length < 3) {
      this.hideMap()
      return
    }

    this.timeout = setTimeout(() => this.geocode(address), 800)
  }

  buildAddress() {
    if (this.hasFullAddressTarget) {
      return this.fullAddressTarget.value.trim()
    }

    const parts = []
    if (this.hasStreetTarget) parts.push(this.streetTarget.value.trim())
    if (this.hasCityTarget) parts.push(this.cityTarget.value.trim())
    if (this.hasStateTarget) parts.push(this.stateTarget.value.trim())
    if (this.hasZipTarget) parts.push(this.zipTarget.value.trim())
    return parts.filter(p => p.length > 0).join(", ")
  }

  async geocode(address) {
    const url = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(address)}&limit=1&countrycodes=us`

    try {
      const response = await fetch(url, {
        headers: { "User-Agent": "RoutenWoodsAdmin/1.0" }
      })
      const data = await response.json()

      if (data.length === 0) {
        this.hideMap()
        this.showError("Address not found")
        return
      }

      this.clearError()
      const lat = parseFloat(data[0].lat)
      const lng = parseFloat(data[0].lon)
      this.showMap(lat, lng)
      this.fetchRoute(lat, lng)
    } catch {
      this.hideMap()
    }
  }

  showMap(lat, lng) {
    this.mapTarget.classList.remove("hidden")
    if (!this.mapTarget.style.minHeight) this.mapTarget.style.minHeight = "200px"

    this.adapter.init(lat, lng, 12)
    this.adapter.setMarker(lat, lng)
    this.adapter.refresh()
  }

  async fetchRoute(lat, lng) {
    if (!this.hasDistanceTarget) return

    const bLat = this.businessLatValue
    const bLng = this.businessLngValue

    const result = await this.adapter.drawRoute(bLat, bLng, lat, lng)

    if (result) {
      const hours = Math.floor(result.durationMinutes / 60)
      const mins = result.durationMinutes % 60
      const time = hours > 0 ? `${hours}h ${mins}m` : `${mins}m`

      this.distanceTarget.textContent = `${result.distanceMiles} mi / ${time} drive from ${this.businessLabelValue}`
      this.distanceTarget.classList.remove("hidden")
    } else {
      this.showFallbackDistance(lat, lng)
    }
  }

  showFallbackDistance(lat, lng) {
    if (!this.hasDistanceTarget) return

    const miles = this.haversine(this.businessLatValue, this.businessLngValue, lat, lng)
    this.distanceTarget.textContent = `~${Math.round(miles * 1.3)} mi (est.) from ${this.businessLabelValue}`
    this.distanceTarget.classList.remove("hidden")
  }

  hideMap() {
    this.mapTarget.classList.add("hidden")
    if (this.hasDistanceTarget) this.distanceTarget.classList.add("hidden")
    this.clearError()
    this.adapter.clearRoute()
  }

  showError(message) {
    if (!this.hasErrorTarget) return
    this.errorTarget.textContent = message
    this.errorTarget.classList.remove("hidden")
  }

  clearError() {
    if (!this.hasErrorTarget) return
    this.errorTarget.classList.add("hidden")
  }

  haversine(lat1, lon1, lat2, lon2) {
    const R = 3959
    const dLat = (lat2 - lat1) * Math.PI / 180
    const dLon = (lon2 - lon1) * Math.PI / 180
    const a = Math.sin(dLat / 2) ** 2 +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLon / 2) ** 2
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  }
}
