FactoryGirl.define do
  factory :checkout, :class => Checkout do |f|
    f.due_date Time.zone.now.next_week
    f.association :item, factory: :item
    f.association :user, factory: :user
    f.association :librarian, factory: :librarian
    f.association :basket, factory: :basket
  end
end
