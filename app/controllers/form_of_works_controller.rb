class FormOfWorksController < InheritedResources::Base
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @form_of_work = FormOfWork.find(params[:id])
    if params[:move]
      move_position(@form_of_work, params[:move])
      return
    end
    update!
  end
end
