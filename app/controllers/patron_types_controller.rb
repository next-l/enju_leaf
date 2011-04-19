class PatronTypesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @patron_type = PatronType.find(params[:id])
    if params[:position]
      @patron_type.insert_at(params[:position])
      redirect_to patron_types_url
      return
    end
    update!
  end

  def index
    @patron_types = @patron_types.paginate(:page => params[:page])
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.patron_type')}
  end
end
