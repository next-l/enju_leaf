# Be sure to restart your server when you modify this file.

#Rails.application.config.session_store :cookie_store, :key => '_enju_leaf_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
#Rails.application.config.session_store :active_record_store

EnjuLeaf::Application.config.session_store :mem_cache_store, :key => '_enju_leaf_session'
#require 'action_dispatch/middleware/session/dalli_store'
#Rails.application.config.session_store :dalli_store, :key => '_enju_leaf_session'
