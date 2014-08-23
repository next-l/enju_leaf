if Rails::VERSION::MAJOR >= 4
  username = 'enjuadmin'
else
  username = 'admin'
end
email = 'admin@example.jp'
password = 'adminpassword'

# Don't edit!

Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
#unless solr = Sunspot.commit rescue nil
#  raise "Solr is not running."
#end

def new_profile
  profile = Profile.new
  profile.user_group = UserGroup.first
  profile.library = Library.real.first
  profile.locale = I18n.default_locale.to_s
  profile
end

#Patron.reindex
#Library.reindex
#Shelf.reindex

system_user = User.new
system_user.username = 'system'
system_user.password = SecureRandom.urlsafe_base64(32)
system_user.email = system_user.email_confirmation = 'root@library.example.jp'
system_user.role = Role.where(name: 'Administrator').first
system_user.save!
system_profile = new_profile
system_profile.user = system_user
system_profile.save!
system_profile.index

user = User.new
user.username = username
user.email = email
user.email_confirmation = email
user.password = password
user.password_confirmation = password
user.operator = user
#user.confirm!
user.role = Role.where(name: 'Administrator').first
user.save!
profile = new_profile
profile.user_number = '0'
profile.user = user
profile.save!
profile.index
Sunspot.commit
puts 'Administrator account created.'
