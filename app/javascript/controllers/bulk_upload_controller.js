import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropzone", "fileInput", "rows", "submitBtn", "emptyState"]
  static values = { tags: Array }

  connect() {
    this.fileCount = 0
  }

  // Drag-and-drop handlers
  dragover(event) {
    event.preventDefault()
    this.dropzoneTarget.classList.add("border-accent", "bg-accent/5")
  }

  dragleave(event) {
    event.preventDefault()
    this.dropzoneTarget.classList.remove("border-accent", "bg-accent/5")
  }

  drop(event) {
    event.preventDefault()
    this.dropzoneTarget.classList.remove("border-accent", "bg-accent/5")
    this.addFiles(event.dataTransfer.files)
  }

  browse() {
    this.fileInputTarget.click()
  }

  selectFiles(event) {
    this.addFiles(event.target.files)
    event.target.value = ""
  }

  addFiles(fileList) {
    const imageFiles = Array.from(fileList).filter(f => f.type.startsWith("image/"))
    if (imageFiles.length === 0) return

    imageFiles.forEach(() => {
      this.fileCount++
    })

    // Reset counter so indices match
    let idx = this.fileCount - imageFiles.length
    imageFiles.forEach((file) => {
      idx++
      this.addRow(file, idx)
    })

    this.submitBtnTarget.classList.remove("hidden")
    if (this.hasEmptyStateTarget) this.emptyStateTarget.classList.add("hidden")
  }

  addRow(file, index) {
    const reader = new FileReader()
    reader.onload = (e) => {
      const card = document.createElement("div")
      card.className = "bg-white rounded-xl border border-gray-200 p-4 flex flex-col sm:flex-row gap-4"
      card.dataset.bulkUploadTarget = "row"

      const tagCheckboxes = this.tagsValue.map(([value, label]) => {
        const checked = value === "gallery" ? "checked" : ""
        return `
          <label class="flex items-center gap-1.5 text-xs text-gray-600 cursor-pointer">
            <input type="checkbox" name="gallery_images[${index}][page_tags][${value}]" value="1" ${checked}
                   class="rounded text-accent focus:ring-accent w-3.5 h-3.5" />
            ${label}
          </label>`
      }).join("")

      card.innerHTML = `
        <div class="flex-shrink-0">
          <img src="${e.target.result}" class="w-20 h-20 object-cover rounded-lg border border-gray-200" />
          <p class="text-xs text-gray-400 truncate max-w-[80px] mt-1">${file.name}</p>
        </div>

        <div class="flex-1 space-y-3">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <input type="text" name="gallery_images[${index}][title]" placeholder="Title (optional)"
                   class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-accent focus:border-accent" />
            <input type="text" name="gallery_images[${index}][description]" placeholder="Description (optional)"
                   class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-accent focus:border-accent" />
          </div>

          <div class="flex flex-wrap gap-x-4 gap-y-2">
            ${tagCheckboxes}
          </div>

          <div class="flex items-center gap-4">
            <div class="flex items-center gap-2">
              <label class="text-xs text-gray-500">Position</label>
              <input type="number" name="gallery_images[${index}][position]" placeholder="#" min="0"
                     class="w-16 px-2 py-1.5 border border-gray-300 rounded-lg text-sm text-center focus:ring-2 focus:ring-accent focus:border-accent" />
            </div>
            <label class="flex items-center gap-1.5 text-xs text-gray-600 cursor-pointer">
              <input type="checkbox" name="gallery_images[${index}][featured]" value="1"
                     class="rounded text-accent focus:ring-accent w-3.5 h-3.5" />
              Featured
            </label>
          </div>
        </div>

        <div class="flex-shrink-0 self-start">
          <button type="button" data-action="bulk-upload#removeRow" class="text-red-400 hover:text-red-600 transition p-1">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
          </button>
        </div>
      `

      card._file = file
      card._index = index

      this.rowsTarget.appendChild(card)
    }
    reader.readAsDataURL(file)
  }

  removeRow(event) {
    const card = event.target.closest("[data-bulk-upload-target='row']")
    card.remove()

    if (this.rowsTarget.children.length === 0) {
      this.submitBtnTarget.classList.add("hidden")
      if (this.hasEmptyStateTarget) this.emptyStateTarget.classList.remove("hidden")
    }
  }

  submit(event) {
    event.preventDefault()

    const rows = this.rowsTarget.querySelectorAll("[data-bulk-upload-target='row']")
    if (rows.length === 0) return

    const form = this.element
    const formData = new FormData()

    const token = document.querySelector('meta[name="csrf-token"]')?.content
    if (token) formData.append("authenticity_token", token)

    rows.forEach((row) => {
      const idx = row._index
      const file = row._file
      const prefix = `gallery_images[${idx}]`

      formData.append(`${prefix}[image]`, file)

      const inputs = row.querySelectorAll("input, select")
      inputs.forEach((input) => {
        if (input.type === "checkbox") {
          formData.append(input.name, input.checked ? "1" : "0")
        } else if (input.type !== "file" && input.name) {
          formData.append(input.name, input.value)
        }
      })
    })

    this.submitBtnTarget.disabled = true
    this.submitBtnTarget.textContent = "Uploading..."

    fetch(form.action, {
      method: "POST",
      body: formData,
      headers: { "Accept": "text/html" }
    }).then(response => {
      if (response.redirected) {
        window.location.href = response.url
      } else {
        window.location.href = form.dataset.successUrl
      }
    }).catch(() => {
      this.submitBtnTarget.disabled = false
      this.submitBtnTarget.textContent = "Upload All"
      alert("Upload failed. Please try again.")
    })
  }
}
