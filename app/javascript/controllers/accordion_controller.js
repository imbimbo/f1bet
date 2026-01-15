import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
    this.rotateIcon()
  }

  rotateIcon() {
    if (!this.hasIconTarget) return

    this.iconTarget.classList.toggle("rotate-180")
    this.iconTarget.classList.add("transition-transform")
  }
}
