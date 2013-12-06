class UserSweeper < ActionController::Caching::Sweeper
  observe User
  def after_save(record)
    case
    when record.is_a?(User)
      I18n.available_locales.each do |locale|
        ['menu'].each do |name|
          expire_fragment(:controller => :page, :user => record.username, :role => record.role.try(:name), :page => name, :locale => locale)
        end
      end
    end
  end

  def after_destroy(record)
    after_save(record)
  end
end
