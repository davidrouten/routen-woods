// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import ahoy from "ahoy.js"

ahoy.configure({ startOnReady: false })

if (!window.location.pathname.startsWith("/admin")) {
  ahoy.start()
  document.addEventListener("turbo:load", () => ahoy.trackView())
}
