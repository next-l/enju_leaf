FactoryGirl.define do
  factory :patron do |f|
    f.sequence(:full_name){|n| "full_name_#{n}"}
    f.patron_type {PatronType.find_by_name('Person')}
    f.country {Country.first}
    f.language {Language.first}
  end
end

FactoryGirl.define do
  factory :invalid_patron, :class => Patron do |f|
  end
end
