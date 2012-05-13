class LanguagesController < InheritedResources::Base
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @language = Language.find(params[:id])
    if params[:move]
      move_position(@language, params[:move])
      return
    end
    update!
  end

  def index
    @languages = @languages.page(params[:page])
  end
end
