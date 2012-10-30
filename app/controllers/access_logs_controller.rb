class AccessLogsController < ApplicationController
  load_and_authorize_resource

  def index
    @access_logs = AccessLog.create_hash
  end
end
