Factory.define :admin, :class => User do |f|
  f.sequence(:username){|n| "admin#{n}"}
  f.sequence(:email){|n| "admin#{n}@example.jp"}
  f.sequence(:email_confirmation){|n| "admin#{n}@example.jp"}
  f.role {Role.find_by_name('Administrator')}
  f.library {Factory(:library)}
  f.password 'adminpassword'
  f.password_confirmation 'adminpassword'
  f.user_group {UserGroup.first}
  f.required_role {Role.find_by_name('User')}
end

Factory.define :librarian, :class => User do |f|
  f.sequence(:username){|n| "librarian#{n}"}
  f.sequence(:email){|n| "librarian#{n}@example.jp"}
  f.sequence(:email_confirmation){|n| "librarian#{n}@example.jp"}
  f.role {Role.find_by_name('Librarian')}
  f.library {Factory(:library)}
  f.password 'librarianpassword'
  f.password_confirmation 'librarianpassword'
  f.user_group {UserGroup.first}
  f.required_role {Role.find_by_name('User')}
end

Factory.define :user, :class => User do |f|
  f.sequence(:username){|n| "user#{n}"}
  f.sequence(:email){|n| "user#{n}@example.jp"}
  f.sequence(:email_confirmation){|n| "user#{n}@example.jp"}
  f.role {Role.find_by_name('User')}
  f.library {Factory(:library)}
  f.password 'userpassword'
  f.password_confirmation 'userpassword'
  f.user_group {UserGroup.first}
  f.required_role {Role.find_by_name('User')}
end

Factory.define :invalid_user, :class => User do |f|
end
