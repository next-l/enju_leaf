class UserSweeper < ActionController::Caching::Sweeper
  observe User
  include Rails.application.routes.url_helpers

  def after_save(record)
    case record.class.to_s.to_sym
    when :User
      I18n.available_locales.each do |locale|
        ['menu'].each do |name|
          ActionController::Base.new.expire_fragment(:controller => :page, :user => record.username, :role => record.role.try(:name), :page => name, :locale => locale)
        end
      end
    end
  end

  def after_destroy(record)
    after_save(record)
  end
end
