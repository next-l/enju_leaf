class LanguagesController < InheritedResources::Base
  respond_to :html, :json
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
