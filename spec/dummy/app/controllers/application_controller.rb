class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery
  enju_leaf
  enju_biblio
  enju_library
end
