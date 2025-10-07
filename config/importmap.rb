# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "book_form_validation", to: "book_form_validation.js"
pin "navbar", to: "navbar.js"
pin "tagify", to: "https://cdn.jsdelivr.net/npm/@yaireo/tagify@4.21.1/dist/tagify.esm.js"
pin "tagify_init", to: "tagify_init.js"