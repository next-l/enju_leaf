username = 'enjuadmin'
email = 'admin@example.jp'
password = 'adminpassword'

# Don't edit the following lines!

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
system_user.email = 'root@library.example.jp'
system_user.role = Role.find_by(name: 'Administrator')
profile = new_profile
profile.save!
system_user.profile = profile
system_user.save!
LibraryGroup.first.update!(user: system_user)

user = User.new
user.username = username
user.email = email
user.password = password
user.password_confirmation = password
#user.confirm!
user.role = Role.find_by(name: 'Administrator')
profile = new_profile
profile.user_number = '0'
profile.save!
user.profile = profile
user.save!
puts 'Administrator account created.'
