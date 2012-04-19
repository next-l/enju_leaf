class SubjectTypesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @subject_type = SubjectType.find(params[:id])
    if params[:move]
      move_position(@subject_type, params[:move])
      return
    end
    update!
  end
end
