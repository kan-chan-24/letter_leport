import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clipboard"
export default class extends Controller {
  static values = { url: String }      // HTMLから受け取るURL
  static targets = ["button", "message"]          // 文言を変えるボタン

  async copy() {
    await navigator.clipboard.writeText(this.urlValue)  // クリップボードにコピー

    const original = this.buttonTarget.textContent
    this.buttonTarget.textContent = "コピーしました ✓"   // 完了表示
    setTimeout(() => {
      this.buttonTarget.textContent = original          // 2秒後に元に戻す
    }, 2000)

    // メッセージを表示して、5秒後に隠す
    this.messageTarget.classList.remove("hidden")
    clearTimeout(this.messageTimer)
    this.messageTimer = setTimeout(() => {
      this.messageTarget.classList.add("hidden")
    }, 5000)
  }
}
