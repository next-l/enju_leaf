class OpacController < ApplicationController
  layout "opac"
  #include Devise::Controllers::InternalHelpers

  def index
    @events = Event.order('start_at DESC').limit(5)
  end

  def search
  end

  def manifestations_index
  end

  def signed_in
    logger.info "OpacController login"
    puts "@@@@v@"
    puts @current_user
  end
end
