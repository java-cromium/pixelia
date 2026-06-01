import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "input", "form", "submit"]

  connect() {
    this.scrollToBottom()
  }

  send(event) {
    event.preventDefault()

    const message = this.inputTarget.value.trim()
    if (!message) return

    this.appendUserMessage(message)
    this.inputTarget.value = ""
    this.inputTarget.style.height = "auto"
    this.submitTarget.disabled = true
    this.showTypingIndicator()

    this.formTarget.requestSubmit()
  }

  handleKeydown(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.formTarget.requestSubmit()
    }
  }

  autoResize() {
    const input = this.inputTarget
    input.style.height = "auto"
    input.style.height = Math.min(input.scrollHeight, 120) + "px"
  }

  appendUserMessage(content) {
    const bubble = document.createElement("div")
    bubble.className = "flex justify-end"
    bubble.innerHTML = `
      <div class="max-w-[80%] bg-cyan-600 text-white rounded-2xl px-4 py-3 shadow-sm">
        <div class="text-sm leading-relaxed whitespace-pre-wrap">${this.escapeHtml(content)}</div>
        <div class="text-[10px] mt-1.5 text-cyan-200">${this.currentTime()}</div>
      </div>
    `
    this.messagesTarget.appendChild(bubble)
    this.scrollToBottom()
  }

  showTypingIndicator() {
    const indicator = document.createElement("div")
    indicator.className = "flex justify-start"
    indicator.id = "typing-indicator"
    indicator.innerHTML = `
      <div class="max-w-[80%] bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-2xl px-4 py-3 shadow-sm">
        <div class="flex items-center gap-2 mb-1.5">
          <span class="w-5 h-5 bg-gradient-to-br from-cyan-400 to-blue-500 rounded-full flex items-center justify-center">
            <svg class="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 20 20"><path d="M10 2a1 1 0 01.894.553l1.789 3.578 3.953.576a1 1 0 01.554 1.706l-2.86 2.788.675 3.937a1 1 0 01-1.451 1.054L10 13.764l-3.554 1.428a1 1 0 01-1.451-1.054l.675-3.937-2.86-2.788a1 1 0 01.554-1.706l3.953-.576L9.106 2.553A1 1 0 0110 2z"/></svg>
          </span>
          <span class="text-xs font-medium text-slate-500 dark:text-slate-400">Pixelia AI</span>
        </div>
        <div class="flex items-center gap-1">
          <span class="w-2 h-2 bg-slate-400 rounded-full animate-bounce" style="animation-delay: 0ms"></span>
          <span class="w-2 h-2 bg-slate-400 rounded-full animate-bounce" style="animation-delay: 150ms"></span>
          <span class="w-2 h-2 bg-slate-400 rounded-full animate-bounce" style="animation-delay: 300ms"></span>
        </div>
      </div>
    `
    this.messagesTarget.appendChild(indicator)
    this.scrollToBottom()
  }

  messagesTargetConnected() {
    this.scrollToBottom()
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = false
    }
    const indicator = document.getElementById("typing-indicator")
    if (indicator) indicator.remove()
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  currentTime() {
    return new Date().toLocaleTimeString([], { hour: "numeric", minute: "2-digit" })
  }
}
