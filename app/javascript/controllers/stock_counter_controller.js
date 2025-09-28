import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="stock-counter"
export default class extends Controller {
  static targets = ["input"]

  decrement() {
    let value = parseInt(this.inputTarget.value || 0)
    this.inputTarget.value = Math.max(0, value - 1)
  }

  increment() {
    let value = parseInt(this.inputTarget.value || 0)
    this.inputTarget.value = value + 1
  }
}
