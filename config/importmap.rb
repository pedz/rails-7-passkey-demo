# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin 'credential'
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@github/webauthn-json/browser-ponyfill", to: "@github--webauthn-json--browser-ponyfill.js" # @2.0.1
