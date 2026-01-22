import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs" // <--- This works now!

export default class extends Controller {
  static targets = ["list", "positionInput", "positionDisplay"]

  connect() {
    this.sortable = Sortable.create(this.listTarget, {
      animation: 150,
      onEnd: this.updateVisuals.bind(this)
    })
  }

  updateVisuals() {
    this.positionDisplayTargets.forEach((element, index) => {
      element.textContent = index + 1
    })
  }

  updateForm(event) {
    // Update position inputs based on current DOM order (after dragging)
    // Get all rows in the current DOM order
    const rows = Array.from(this.listTarget.querySelectorAll('tr[data-id]'))
    
    rows.forEach((row, index) => {
      const position = index + 1
      
      // Find the position input within this row
      const positionInput = row.querySelector('[data-sortable-target="positionInput"]')
      if (positionInput) {
        positionInput.value = position
        // Set the value attribute directly to ensure it's in the form data
        positionInput.setAttribute('value', position)
      }
      
      // Also update the visual display
      const positionDisplay = row.querySelector('[data-sortable-target="positionDisplay"]')
      if (positionDisplay) {
        positionDisplay.textContent = position
      }
    })
    
    // For click events on submit buttons, ensure form submits after positions are updated
    if (event && event.type === 'click' && event.target.type === 'submit') {
      // Don't prevent default - let the form submit normally
      // The submit event will also trigger this method via the form's submit action
    }
  }
}
