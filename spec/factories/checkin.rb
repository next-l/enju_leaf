FactoryGirl.define do
  factory :checkin, :class => Checkin do |f|
  end

  factory :checkin_libraryA, :class => Checkin do |f|
    f.librarian_id{User.where("username like 'adult_%'").first.id}
    f.basket{Basket.first}
    f.item_identifier "000000"
  end
  factory :checkin_libraryB, :class => Checkin do |f|
    f.librarian_id{User.where("username like 'juniors_%'").first.id}
    f.basket{Basket.first}
    f.item_identifier "000000"
  end
end
