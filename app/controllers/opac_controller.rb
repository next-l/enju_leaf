class OpacController < ApplicationController
  layout "opac"

  def index
    @events = Event.order('start_at DESC').limit(5)
  end

  def search
  end

  def manifestations_index
  end

end
