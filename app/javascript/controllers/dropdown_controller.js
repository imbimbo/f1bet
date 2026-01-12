import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "container"]

  connect() {
    // Close dropdown when clicking outside
    this.boundClickOutside = this.clickOutside.bind(this)
    document.addEventListener("click", this.boundClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.boundClickOutside)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  clickOutside(event) {
    if (!this.containerTarget.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }
}

