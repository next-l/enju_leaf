class ApplicationController < ActionController::Base
  protect_from_forgery
  enju_leaf
  enju_biblio
  enju_library
end
