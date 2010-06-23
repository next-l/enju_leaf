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
    role_names = Role.all.collect(&:name)
    role_names.each do |name|
      expire_fragment(:controller => :page, :role_name => name)
    end
  end

end
