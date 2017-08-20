# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
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
  profile.full_name = 'System'
  profile
end

#Patron.reindex
#Library.reindex
#Shelf.reindex

system_user = User.find_by(username: 'system') || User.new
system_user.username = 'system'
system_user.password = SecureRandom.urlsafe_base64(32)
system_user.email = 'root@library.example.jp'
system_user.role = Role.where(name: 'Administrator').first
system_profile = new_profile
system_profile.save!
system_user.profile = system_profile
system_user.save!

user = User.new
user.username = username
user.email = email
user.password = password
user.password_confirmation = password
#user.confirm!
user.role = Role.where(name: 'Administrator').first
profile = new_profile
profile.user_number = '0'
profile.save!
user.profile = profile
user.save!
puts 'Administrator account created.'
