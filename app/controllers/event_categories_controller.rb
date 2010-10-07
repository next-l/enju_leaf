class EventCategoriesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @event_category = EventCategory.find(params[:id])
    if params[:position]
      @event_category.insert_at(params[:position])
      redirect_to event_categories_url
      return
    end
    update!
  end

  def index
    @event_categories = @event_categories.paginate(:page => params[:page])
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.event_category')}
  end
end
