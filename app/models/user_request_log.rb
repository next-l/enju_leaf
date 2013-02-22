class UserRequestLog < ActiveRecord::Base
  attr_accessible :action, :controller, :data, :remote_ip, :user_id
  serialize :data

  paginates_per 50

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
