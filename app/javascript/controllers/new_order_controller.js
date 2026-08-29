import { Controller } from "@hotwired/stimulus"

// Cards rendered with the page connect before load, so only streamed-in orders notify.
export default class extends Controller {
  static values = { title: String }

  connect() {
    if (Notification.permission === "default") Notification.requestPermission()
    if (document.readyState !== "complete") return
    if (Notification.permission === "granted") new Notification(this.titleValue)
  }
}
