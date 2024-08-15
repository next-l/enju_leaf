// Entry point for the build script in your package.json
import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "bootstrap"
import "@oddcamp/cocoon-vanilla-js"
import jquery from "jquery"
window.$ = jquery
window.jQuery = jquery

Rails.start()
ActiveStorage.start()
