class LanguagesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @language = Language.find(params[:id])
    if params[:position]
      @language.insert_at(params[:position])
      redirect_to languages_url
      return
    end
    update!
  end

  def index
    @languages = @languages.paginate(:page => params[:page])
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.language')}
  end
end
