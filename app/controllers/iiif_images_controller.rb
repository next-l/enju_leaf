class IiifImagesController < ActionController::API
  include Pundit::Authorization
  after_action :verify_authorized
  
  def show
    @manifestation = Manifestation.find(params[:id])
    authorize @manifestation
  end
end
