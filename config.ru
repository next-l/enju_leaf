# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require 'rack/protection'
use Rack::Protection, :except => [:escaped_params, :json_csrf, :http_origin, :session_hijacking, :remote_token]
run EnjuLeaf::Application
