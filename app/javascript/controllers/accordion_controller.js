import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon", "button", "text"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
    this.rotateIcon()
    this.toggleButtonActive()
  }

  rotateIcon() {
    if (!this.hasIconTarget) return

    this.iconTarget.classList.toggle("rotate-180")
    this.iconTarget.classList.add("transition-transform")
  }

  toggleButtonActive() {
    if (!this.hasButtonTarget) return

    const isOpen = !this.contentTarget.classList.contains("hidden")
    
    if (isOpen) {
      this.buttonTarget.classList.remove("bg-[#0a0a0a]")
      this.buttonTarget.classList.add("bg-[#FF8700]")
      
      // Change text and icon to dark color
      if (this.hasTextTarget) {
        this.textTarget.classList.remove("text-white")
        this.textTarget.classList.add("text-[#0a0a0a]")
      }
      if (this.hasIconTarget) {
        this.iconTarget.classList.remove("text-white")
        this.iconTarget.classList.add("text-[#0a0a0a]")
      }
    } else {
      this.buttonTarget.classList.remove("bg-[#FF8700]")
      this.buttonTarget.classList.add("bg-[#0a0a0a]")
      
      // Change text and icon back to white
      if (this.hasTextTarget) {
        this.textTarget.classList.remove("text-[#0a0a0a]")
        this.textTarget.classList.add("text-white")
      }
      if (this.hasIconTarget) {
        this.iconTarget.classList.remove("text-[#0a0a0a]")
        this.iconTarget.classList.add("text-white")
      }
    }
  }
}
