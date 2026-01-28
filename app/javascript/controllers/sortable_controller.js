import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs" // <--- This works now!

export default class extends Controller {
  static targets = ["list", "positionInput", "positionDisplay", "headshot", "driverName", "teamName"]

  connect() {
    this.sortable = Sortable.create(this.listTarget, {
      animation: 150,
      onEnd: this.updateVisuals.bind(this)
    })
  }

  updateVisuals() {
    const rows = Array.from(this.listTarget.querySelectorAll('tr[data-id]'))
    
    rows.forEach((row, index) => {
      const position = index + 1
      
      // Update position display
      const positionDisplay = row.querySelector('[data-sortable-target="positionDisplay"]')
      if (positionDisplay) {
        const positionNumber = positionDisplay.querySelector('.position-number')
        if (positionNumber) {
          positionNumber.textContent = position
        } else {
          positionDisplay.textContent = position
        }
        
        // Update data-position attribute
        positionDisplay.setAttribute('data-position', position)
        
        // Update color classes based on new position
        this.updatePositionColor(positionDisplay, position)
      }
      
      // Update headshot opacity
      const headshot = row.querySelector('[data-sortable-target="headshot"]')
      if (headshot) {
        this.updateHeadshotOpacity(headshot, position)
      }
      
      // Update driver name opacity
      const driverName = row.querySelector('[data-sortable-target="driverName"]')
      if (driverName) {
        this.updateDriverNameOpacity(driverName, position)
      }
      
      // Update team name opacity
      const teamName = row.querySelector('[data-sortable-target="teamName"]')
      if (teamName) {
        this.updateTeamNameOpacity(teamName, position)
      }
    })
  }
  
  updatePositionColor(element, position) {
    // Remove all position color classes
    element.classList.remove(
      'text-yellow-400', 'drop-shadow-[0_0_8px_rgba(250,204,21,0.5)]',
      'text-gray-300', 'text-orange-400', 'text-white', 'text-gray-600'
    )
    
    // Apply appropriate color based on position
    if (position === 1) {
      element.classList.add('text-yellow-400', 'drop-shadow-[0_0_8px_rgba(250,204,21,0.5)]')
    } else if (position === 2) {
      element.classList.add('text-gray-300')
    } else if (position === 3) {
      element.classList.add('text-orange-400')
    } else if (position >= 4 && position <= 10) {
      element.classList.add('text-white')
    } else {
      element.classList.add('text-gray-600')
    }
  }
  
  updateHeadshotOpacity(headshot, position) {
    // Dim headshots below position 10
    if (position > 10) {
      headshot.classList.remove('opacity-100')
      headshot.classList.add('opacity-40')
    } else {
      headshot.classList.remove('opacity-40')
      headshot.classList.add('opacity-100')
    }
  }
  
  updateDriverNameOpacity(driverName, position) {
    // Dim driver names below position 10
    if (position > 10) {
      driverName.classList.remove('opacity-100')
      driverName.classList.add('opacity-40')
    } else {
      driverName.classList.remove('opacity-40')
      driverName.classList.add('opacity-100')
    }
  }
  
  updateTeamNameOpacity(teamName, position) {
    // Dim team names below position 10
    if (position > 10) {
      teamName.classList.remove('opacity-100')
      teamName.classList.add('opacity-40')
    } else {
      teamName.classList.remove('opacity-40')
      teamName.classList.add('opacity-100')
    }
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
        const positionNumber = positionDisplay.querySelector('.position-number')
        if (positionNumber) {
          positionNumber.textContent = position
        } else {
          positionDisplay.textContent = position
        }
        
        // Update data-position attribute
        positionDisplay.setAttribute('data-position', position)
        
        // Update color classes based on new position
        this.updatePositionColor(positionDisplay, position)
      }
      
      // Update headshot opacity
      const headshot = row.querySelector('[data-sortable-target="headshot"]')
      if (headshot) {
        this.updateHeadshotOpacity(headshot, position)
      }
      
      // Update driver name opacity
      const driverName = row.querySelector('[data-sortable-target="driverName"]')
      if (driverName) {
        this.updateDriverNameOpacity(driverName, position)
      }
      
      // Update team name opacity
      const teamName = row.querySelector('[data-sortable-target="teamName"]')
      if (teamName) {
        this.updateTeamNameOpacity(teamName, position)
      }
    })
    
    // For click events on submit buttons, ensure form submits after positions are updated
    if (event && event.type === 'click' && event.target.type === 'submit') {
      // Don't prevent default - let the form submit normally
      // The submit event will also trigger this method via the form's submit action
    }
  }
}
