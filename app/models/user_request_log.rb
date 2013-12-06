class UserRequestLog < ActiveRecord::Base
  attr_accessible :action, :controller, :data, :remote_ip, :user_id
  serialize :data

  paginates_per 50

  def self.search_fields_and(params, sort = {:sort_by => 'id', :order => 'desc'})
    t = self.arel_table
    user_request_logs = self.order("#{sort[:sort_by]} #{sort[:order]}")
    if params[:user_id].present?
      user_request_logs = user_request_logs.where(:user_id => params[:user_id])
    end
    if params[:controller_name].present?
      user_request_logs = user_request_logs.where(t[:controller].matches(params[:controller_name]))
    end
    if params[:action_name].present?
      user_request_logs = user_request_logs.where(t[:action].matches(params[:action_name]))
    end
    if params[:remote_ip].present?
      user_request_logs = user_request_logs.where(t[:remote_ip].matches(params[:remote_ip]))
    end
    if params[:created_at_start].present?
      user_request_logs = user_request_logs.where("created_at >= ?", params[:created_at_start])
    end
    if params[:created_at_end].present?
      user_request_logs = user_request_logs.where("created_at <= ?", params[:created_at_end])
    end
    return user_request_logs
  end

  class Subscriber < ActiveSupport::LogSubscriber
    def process_action(event)
      payload = event.payload
      attrs = {}

      begin
        attrs[:user_id] = payload[:current_user].try(:id)
        [
          :controller, :action, :remote_ip,
        ].each {|s| attrs[s] = payload[s] }

        attrs[:data] = {}
        [
          :method, :path, :format, :status, :session_id,
        ].each {|s| attrs[:data][s] = payload[s] }
        attrs[:data][:params] = payload[:params].except('controller', 'action')

        UserRequestLog.create!(attrs)

      rescue => e
        logger.warn "user request log failed: #{e.message} (#{e.class}): #{attrs.inspect}"
      end
    end

    def logger
      ActiveRecord::Base.logger
    end
  end
end
