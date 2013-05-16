FactoryGirl.define do
  factory :type_user, :class => 'PatronType' do |f|
    f.sequence(:name){"User"}
    f.sequence(:display_name){"User"}
  end
end
