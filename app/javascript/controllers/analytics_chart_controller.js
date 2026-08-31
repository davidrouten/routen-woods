import { Controller } from "@hotwired/stimulus"
import { LineChart } from "chartist"

export default class extends Controller {
  static values = { series: Array, labels: Array }

  connect() {
    new LineChart(this.element, {
      labels: this.labelsValue,
      series: this.seriesValue
    }, {
      fullWidth: true,
      low: 0,
      showArea: true,
      showPoint: true,
      axisX: { showGrid: false },
      axisY: { onlyInteger: true }
    })
  }
}
