username = 'admin'
email = 'admin@example.jp'
password = 'adminpassword'

# Don't edit!

Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
#unless solr = Sunspot.commit rescue nil
#  raise "Solr is not running."
#end

#Patron.reindex
#Library.reindex
#Shelf.reindex

system_user = User.new
system_user.username = 'system'
system_user.password = SecureRandom.urlsafe_base64(32)
system_user.email = system_user.email_confirmation = LibraryGroup.first.email
system_user.save!
system_user.role = Role.where(:name => 'Administrator').first
system_user.index

user = User.new
user.username = username
user.email = email
user.email_confirmation = email
user.password = password
user.password_confirmation = password
user.library = Library.real.first
user.locale = I18n.default_locale.to_s
user.user_number = '0'
user.operator = user
user.save!
#user.confirm!
user.role = Role.where(:name => 'Administrator').first
user.index
Sunspot.commit
puts 'Administrator account created.'
