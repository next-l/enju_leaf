# Be sure to restart your server when you modify this file.

#EnjuLeaf::Application.config.session_store :cookie_store, :key => '_enju_leaf_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
#EnjuLeaf::Application.config.session_store :active_record_store

require 'action_dispatch/middleware/session/dalli_store'
EnjuLeaf::Application.config.session_store :dalli_store, :key => '_enju_leaf_session'
