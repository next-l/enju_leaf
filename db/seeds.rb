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

Rake::Task['enju_leaf:setup'].invoke

if User.count.zero?
  system_user = User.new(
    username: 'system',
    email: 'root@library.example.jp',
    role: Role.find_by(name: 'Administrator')
  )
  system_user.password = SecureRandom.urlsafe_base64(32)
  profile = new_profile
  profile.save!
  system_user.profile = profile
  system_user.save!
  LibraryGroup.first.update!(
    email: system_user.email,
    url: ENV['ENJU_LEAF_BASE_URL']
  )
  UserGroup.order(created_at: :desc).first.update!(
    number_of_day_to_notify_overdue: 7,
    number_of_day_to_notify_due_date: 3
  )

  user = User.new(
    username: username,
    email: email,
    role: Role.find_by(name: 'Administrator')
  )
  user.password = password
  user.password_confirmation = password
  profile = new_profile
  profile.user_number = '0'
  profile.save!
  user.profile = profile
  user.save!
  puts 'Administrator account created.'
end
