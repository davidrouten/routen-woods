import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropzone", "fileInput", "rows", "submitBtn", "emptyState"]

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
    // Reset so the same files can be re-selected if removed
    event.target.value = ""
  }

  addFiles(fileList) {
    const imageFiles = Array.from(fileList).filter(f => f.type.startsWith("image/"))
    if (imageFiles.length === 0) return

    imageFiles.forEach((file, i) => {
      this.fileCount++
      this.addRow(file, this.fileCount)
    })

    this.submitBtnTarget.classList.remove("hidden")
    if (this.hasEmptyStateTarget) this.emptyStateTarget.classList.add("hidden")
  }

  addRow(file, index) {
    const reader = new FileReader()
    reader.onload = (e) => {
      const row = document.createElement("tr")
      row.className = "border-b border-gray-100"
      row.dataset.bulkUploadTarget = "row"

      row.innerHTML = `
        <td class="px-4 py-3">
          <div class="flex items-center gap-3">
            <img src="${e.target.result}" class="w-16 h-16 object-cover rounded-lg border border-gray-200" />
            <span class="text-xs text-gray-400 truncate max-w-[120px]">${file.name}</span>
          </div>
        </td>
        <td class="px-4 py-3">
          <input type="text" name="gallery_images[${index}][title]" placeholder="Optional title"
                 class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-accent focus:border-accent" />
        </td>
        <td class="px-4 py-3">
          <input type="text" name="gallery_images[${index}][description]" placeholder="Optional description"
                 class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-accent focus:border-accent" />
        </td>
        <td class="px-4 py-3">
          <select name="gallery_images[${index}][category]"
                  class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-accent focus:border-accent">
            <option value="">None</option>
            <option value="before_after">Before & After</option>
            <option value="completed">Completed</option>
            <option value="process">Process</option>
          </select>
        </td>
        <td class="px-4 py-3">
          <input type="number" name="gallery_images[${index}][position]" placeholder="#" min="0"
                 class="w-20 px-3 py-2 border border-gray-300 rounded-lg text-sm text-center focus:ring-2 focus:ring-accent focus:border-accent" />
        </td>
        <td class="px-4 py-3 text-center">
          <input type="checkbox" name="gallery_images[${index}][featured]" value="1"
                 class="w-4 h-4 rounded border-gray-300 text-accent focus:ring-accent" />
        </td>
        <td class="px-4 py-3 text-center">
          <button type="button" data-action="bulk-upload#removeRow" class="text-red-400 hover:text-red-600 transition">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
          </button>
        </td>
      `

      // Store the File object on the row so we can grab it at submit time
      row._file = file
      row._index = index

      this.rowsTarget.appendChild(row)
    }
    reader.readAsDataURL(file)
  }

  removeRow(event) {
    const row = event.target.closest("tr")
    row.remove()

    // Hide submit and show empty state if no rows left
    if (this.rowsTarget.children.length === 0) {
      this.submitBtnTarget.classList.add("hidden")
      if (this.hasEmptyStateTarget) this.emptyStateTarget.classList.remove("hidden")
    }
  }

  submit(event) {
    event.preventDefault()

    const rows = this.rowsTarget.querySelectorAll("tr")
    if (rows.length === 0) return

    const form = this.element
    const formData = new FormData()

    // Add CSRF token
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

    // Disable submit button
    this.submitBtnTarget.disabled = true
    this.submitBtnTarget.textContent = "Uploading..."

    fetch(form.action, {
      method: "POST",
      body: formData,
      headers: {
        "Accept": "text/html"
      }
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
