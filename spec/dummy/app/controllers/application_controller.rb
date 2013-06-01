class ApplicationController < ActionController::Base
  protect_from_forgery
  enju_leaf

  mobylette_config do |config|
    config[:skip_xhr_requests] = false
    config[:skip_user_agents] = Setting.enju.skip_mobile_agents.map{|a| a.to_sym}
  end
end
