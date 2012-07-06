FactoryGirl.define do
  factory :basket, :class => Basket do |f|
    f.user_id{FactoryGirl.create(:user).id}
  end

  factory :adult_basket, :class => Basket do |f|
    f.user_id{User.where("username like 'adult%'").first.id}
  end

  factory :student_basket, :class => Basket do |f|
    f.user_id{User.where("username like 'student%'").first.id}
  end

  factory :juniors_basket, :class => Basket do |f|
    f.user_id{User.where("username like 'juniors%'").first.id}
  end

  factory :elements_basket, :class => Basket do |f|
    f.user_id{User.where("username like 'elements%'").first.id}
  end

  factory :children_basket, :class => Basket do |f|
    f.user_id{User.where("username like 'children%'").first.id}
  end
end
