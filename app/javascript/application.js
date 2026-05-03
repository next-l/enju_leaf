// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()
import "@popperjs/core"
import "bootstrap"
import "@oddcamp/cocoon-vanilla-js"
import tom_select from "tom-select"
window.TomSelect = tom_select
import jQuery from "jquery"
window.$ = window.jQuery = jQuery
import Rails from '@rails/ujs'
Rails.start()
