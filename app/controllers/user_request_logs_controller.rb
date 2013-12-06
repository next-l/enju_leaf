class UserRequestLogsController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def index
    sort = {:sort_by => 'id', :order => 'desc'}
    page = params[:page] || 1

    sort[:order] = 'asc' if params[:order] == 'asc'

    if params[:created_at_start].present?
#      params[:created_at_start] 
    end

    @user_request_logs = UserRequestLog.search_fields_and(params, sort).page(page)

  end
end
