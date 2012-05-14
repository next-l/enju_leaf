class EventCategoriesController < InheritedResources::Base
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource :except => [:update]

  def update
    unless current_user.has_role?('Administrator')
      access_denied; return
    end

    @event_category = EventCategory.find(params[:id])
    if current_user.has_role?('Administrator') and params[:move]
      move_position(@event_category, params[:move])
      return
    end
    update!
  end

  def index
    @event_categories = @event_categories.page(params[:page])
  end
end
