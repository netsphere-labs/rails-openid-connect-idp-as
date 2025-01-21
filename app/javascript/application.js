// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// "turbo:load" でも呼び出されるはずだが,
// これがないと, 初回が動作しない。
Bulma.parseDocument();

document.addEventListener("turbo:load", () => {
  Bulma.parseDocument();
});
