class UserRequestLogsController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def index
    sort = {:sort_by => 'id', :order => 'desc'}
    page = params[:page] || 1

    sort[:order] = 'asc' if params[:order] == 'asc'

    search_hash = {}

    t = UserRequestLog.arel_table
    @user_request_logs = UserRequestLog.order("#{sort[:sort_by]} #{sort[:order]}")
    if params[:user_id].present?
      @user_request_logs = @user_request_logs.where(:user_id => params[:user_id])
    end
    if params[:controller_name].present?
      @user_request_logs = @user_request_logs.where(t[:controller].matches(params[:controller_name]))
    end
    if params[:action_name].present?
      @user_request_logs = @user_request_logs.where(t[:action].matches(params[:action_name]))
    end
    if params[:remote_ip].present?
      @user_request_logs = @user_request_logs.where(t[:remote_ip].matches(params[:remote_ip]))
    end
    if params[:created_at_start].present?
      @user_request_logs = @user_request_logs.where("created_at >= ?", params[:created_at_start])
    end
    if params[:created_at_end].present?
      @user_request_logs = @user_request_logs.where("created_at <= ?", params[:created_at_end])
    end
    @user_request_logs = @user_request_logs.page(page)

  end
end
