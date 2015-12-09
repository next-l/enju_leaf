class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery
  include EnjuLeaf::Controller
  enju_biblio
  enju_library
end
