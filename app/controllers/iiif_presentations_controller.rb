class IiifPresentationsController < ApplicationController
  def show
    @manifestation = Manifestation.find(params[:id])
    authorize @manifestation
  end
end
