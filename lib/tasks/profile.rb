def update_profile
  User.find_each do |user|
    next if user.profile
    profile = Profile.new
    profile.user = user
    profile.user_group = user.user_group
    profile.library = user.library
    profile.required_role = user.required_role
    profile.user_number = user.user_number
    profile.keyword_list = user.keyword_list
    profile.locale = user.locale
    profile.note = user.note
    profile.save!
  end
end
