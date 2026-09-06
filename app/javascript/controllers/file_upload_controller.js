import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropzone", "fileInput", "fileList", "submitBtn"]

  connect() {
    this.files = []
  }

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

  browse(event) {
    if (event) event.stopPropagation()
    this.fileInputTarget.click()
  }

  selectFiles(event) {
    this.addFiles(event.target.files)
    event.target.value = ""
  }

  addFiles(fileList) {
    const newFiles = Array.from(fileList)
    if (newFiles.length === 0) return

    newFiles.forEach(file => {
      this.files.push(file)
      this.addFileRow(file, this.files.length - 1)
    })

    this.submitBtnTarget.classList.remove("hidden")
  }

  addFileRow(file, index) {
    const row = document.createElement("div")
    row.className = "flex items-center justify-between p-2 rounded-lg bg-gray-50 text-sm"
    row.dataset.fileIndex = index

    const icon = this.iconForType(file.type)
    const size = this.formatSize(file.size)

    row.innerHTML = `
      <div class="flex items-center gap-2 min-w-0">
        <span class="text-gray-400 flex-shrink-0">${icon}</span>
        <span class="truncate font-medium text-gray-700">${file.name}</span>
        <span class="text-gray-400 flex-shrink-0">${size}</span>
      </div>
      <button type="button" data-action="file-upload#removeFile" data-index="${index}"
              class="text-red-400 hover:text-red-600 flex-shrink-0 ml-2 cursor-pointer">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
        </svg>
      </button>
    `
    this.fileListTarget.appendChild(row)
  }

  removeFile(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.files[index] = null
    const row = this.fileListTarget.querySelector(`[data-file-index="${index}"]`)
    if (row) row.remove()

    if (this.files.every(f => f === null)) {
      this.submitBtnTarget.classList.add("hidden")
    }
  }

  submit(event) {
    event.preventDefault()

    const activeFiles = this.files.filter(f => f !== null)
    if (activeFiles.length === 0) return

    const form = this.element
    const formData = new FormData()

    const token = document.querySelector('meta[name="csrf-token"]')?.content
    if (token) formData.append("authenticity_token", token)

    activeFiles.forEach(file => {
      formData.append("files[]", file)
    })

    const description = form.querySelector('[name="description"]')
    if (description && description.value) {
      formData.append("description", description.value)
    }

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
        window.location.reload()
      }
    }).catch(() => {
      this.submitBtnTarget.disabled = false
      this.submitBtnTarget.textContent = "Upload"
      alert("Upload failed. Please try again.")
    })
  }

  iconForType(type) {
    if (type.startsWith("image/")) return `<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>`
    if (type === "application/pdf") return `<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"/></svg>`
    return `<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>`
  }

  formatSize(bytes) {
    if (bytes < 1024) return `${bytes} B`
    if (bytes < 1048576) return `${(bytes / 1024).toFixed(1)} KB`
    return `${(bytes / 1048576).toFixed(1)} MB`
  }
}
