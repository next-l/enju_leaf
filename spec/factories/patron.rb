FactoryGirl.define do
  factory :patron do |f|
    f.sequence(:full_name){|n| "full_name_#{n}"}
    f.patron_type_id{PatronType.find_by_name('Person').id}
    f.country_id{Country.first.id}
    f.language_id{Language.first.id}
  end
end

FactoryGirl.define do
  factory :invalid_patron, :class => Patron do |f|
  end
end
