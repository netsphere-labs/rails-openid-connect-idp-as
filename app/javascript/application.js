// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

Bulma.parseDocument();

document.addEventListener("turbo:load", () => {
  Bulma.parseDocument();
});
