class LicensesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @license = License.find(params[:id])
    if params[:position]
      @license.insert_at(params[:position])
      redirect_to licenses_url
      return
    end
    update!
  end

  def index
    @licenses = @licenses.page(params[:page])
  end
end
