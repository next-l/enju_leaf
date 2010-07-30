class PageSweeper < ActionController::Caching::Sweeper
  observe Library, Role #, User
  def after_save(record)
    case
    when record.is_a?(Role)
      expire_page_fragment
    when record.is_a?(Library)
      #expire_fragment(:controller => :libraries, :action => :index, :page => 'menu')
      expire_page_fragment
    end
  end

  def after_destroy(record)
    after_save(record)
  end

  def expire_page_fragment
    Rails.cache.fetch('role_all'){Role.all}.each do |role|
      expire_fragment(:controller => :page, :role_name => role.name)
    end
  end

end
