import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "position"]
  static values = { url: String }

  connect() {
    this.rowTargets.forEach(row => {
      row.addEventListener("dragstart", () => {
        this.draggedRow = row
        this.startIndex = this.rowTargets.indexOf(row)
        row.classList.add("ring-2", "ring-green-500", "bg-gray-800")
      })

      row.addEventListener("dragend", () => {
        this.draggedRow = null
        row.classList.remove("ring-2", "ring-green-500", "bg-gray-800")
        this.updatePositions()
      })

      row.addEventListener("dragover", e => e.preventDefault())

      row.addEventListener("dragenter", () => {
        if (!this.draggedRow || row === this.draggedRow) return

        const targetIndex = this.rowTargets.indexOf(row)

        if (targetIndex > this.startIndex) {
          row.after(this.draggedRow)
        } else {
          row.before(this.draggedRow)
        }

        this.startIndex = targetIndex
      })
    })
  }

  updatePositions() {
    this.rowTargets.forEach((row, index) => {
      row.querySelector("[data-sortable-target='position']").innerText = index + 1
    })
  }

  save() {

    console.log("rows:", this.rowTargets);

  const positions = this.rowTargets.map((row, index) => ({
    driver_id: row.dataset.driverId,
    position: index + 1
  }))

  fetch(this.urlValue, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
    },
    body: JSON.stringify({ positions })
  })
    .then(response => {
      if (!response.ok) throw new Error("Erro ao salvar aposta")
      return response.text()
    })
    // .then(() => {
    //   alert("Aposta salva com sucesso ✅")
    // })
    .catch(error => {
      alert("Erro ao salvar a aposta ❌")
      console.error(error)
    })
  }

  confirm() {
    const confirmed = window.confirm(
      "Confirmar a sua aposta ?"
    )

    if (confirmed) {
      this.save()
    }
  }


}
