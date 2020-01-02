import 'bootstrap'
import '../src/cocoon.js'
import '../src/application.scss'

import Rails from '@rails/ujs'
Rails.start()

import * as ActiveStorage from '@rails/activestorage'
ActiveStorage.start()
