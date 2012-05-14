class CountriesController < InheritedResources::Base
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @country = Country.find(params[:id])
    if params[:move]
      move_position(@country, params[:move])
      return
    end
    update!
  end

  def index
    @countries = @countries.page(params[:page])
  end
end
