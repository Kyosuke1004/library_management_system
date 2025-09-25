// application.js
import "@hotwired/turbo-rails"
import "controllers"
import "./author_autocomplete"
import { setupNavbar } from "./navbar"
import { setupAuthorInputValidation } from "./book_form_validation"

// Turbo対応: ページロードごとに必ず実行される
document.addEventListener('turbo:load', () => {
  setupNavbar();
  setupAuthorInputValidation();
});
