FactoryGirl.define do
  factory :reserve do |f|
    f.manifestation{FactoryGirl.create(:manifestation)}
    f.user{FactoryGirl.create(:user)}
    f.expired_at 1.week.from_now
    f.created_by 1
  end
  
  factory :reserve_by_librarian, :class => Reserve do |f|
    f.manifestation{FactoryGirl.create(:manifestation)}
    f.user{User.where("username like 'juniors_%'").last}
    f.expired_at 1.week.from_now
    f.created_by {User.where("username like 'adult_%'").last.id}
    f.receipt_library_id {Library.find_by_name("libb").id}
  end

  factory :reserve_by_user, :class => Reserve do |f|
    f.manifestation{FactoryGirl.create(:manifestation)}
    f.user{User.where("username like 'student_%'").last}
    f.expired_at 1.week.from_now
    f.created_by {User.where("username like 'student_%'").last.id}
    f.receipt_library_id {Library.find_by_name("liba").id}
  end
end
