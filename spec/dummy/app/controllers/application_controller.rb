class ApplicationController < ActionController::Base
  protect_from_forgery
  enju_leaf
  enju_biblio
  enju_library

  private
  def mobylette_options
    @mobylette_options ||= ApplicationController.send(:mobylette_options).merge(
      {
        :skip_xhr_requests => false
      }
    )
  end
end
