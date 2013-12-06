class AccessLogsController < ApplicationController
  add_breadcrumb "I18n.t('page.access_logs')", 'access_logs_path', :only => [:index]
  load_and_authorize_resource

  def index
    @access_logs = AccessLog.create_hash
  end
end
