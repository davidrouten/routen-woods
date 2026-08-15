import L from "leaflet"

export default class LeafletAdapter {
  constructor(element) {
    this.element = element
    this.map = null
    this.marker = null
    this.businessMarker = null
    this.routeLine = null
  }

  init(lat, lng, zoom = 12) {
    if (this.map) {
      this.setView(lat, lng, zoom)
      return
    }

    this.map = L.map(this.element, { zoomControl: false, attributionControl: false })
      .setView([lat, lng], zoom)

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 18
    }).addTo(this.map)

    L.control.zoom({ position: "bottomright" }).addTo(this.map)
  }

  setView(lat, lng, zoom = 12) {
    if (!this.map) return
    this.map.setView([lat, lng], zoom)
  }

  setMarker(lat, lng) {
    if (!this.map) return

    if (this.marker) {
      this.marker.setLatLng([lat, lng])
    } else {
      this.marker = L.circleMarker([lat, lng], {
        radius: 8,
        fillColor: "#3b82f6",
        color: "#fff",
        weight: 2,
        opacity: 1,
        fillOpacity: 0.9
      }).addTo(this.map)
    }
  }

  drawRoute(fromLat, fromLng, toLat, toLng) {
    if (!this.map) return Promise.resolve(null)

    const url = `https://router.project-osrm.org/route/v1/driving/${fromLng},${fromLat};${toLng},${toLat}?overview=full&geometries=geojson`

    return fetch(url)
      .then(r => r.json())
      .then(data => {
        if (!data.routes || data.routes.length === 0) return null

        const route = data.routes[0]

        if (this.routeLine) this.map.removeLayer(this.routeLine)
        if (this.businessMarker) this.map.removeLayer(this.businessMarker)

        this.routeLine = L.geoJSON(route.geometry, {
          style: { color: "#3b82f6", weight: 3, opacity: 0.6 }
        }).addTo(this.map)

        this.businessMarker = L.circleMarker([fromLat, fromLng], {
          radius: 6,
          fillColor: "#6b7280",
          color: "#fff",
          weight: 2,
          opacity: 1,
          fillOpacity: 0.8
        }).addTo(this.map)

        const bounds = L.latLngBounds([[fromLat, fromLng], [toLat, toLng]])
        this.map.fitBounds(this.routeLine.getBounds().extend(bounds), { padding: [30, 30] })

        return {
          distanceMiles: Math.round(route.distance / 1609.34),
          durationMinutes: Math.round(route.duration / 60)
        }
      })
      .catch(() => null)
  }

  clearRoute() {
    if (this.routeLine) { this.map.removeLayer(this.routeLine); this.routeLine = null }
    if (this.businessMarker) { this.map.removeLayer(this.businessMarker); this.businessMarker = null }
  }

  refresh() {
    if (this.map) {
      setTimeout(() => this.map.invalidateSize(), 100)
    }
  }

  destroy() {
    if (this.map) {
      this.map.remove()
      this.map = null
      this.marker = null
      this.businessMarker = null
      this.routeLine = null
    }
  }
}
