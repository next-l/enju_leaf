FactoryGirl.define do
  factory :patron, :class => 'Patron' do |f|
    f.sequence(:full_name){|n| "full_name_#{n}"}
    f.patron_type_id{PatronType.find_by_name('Person').id}
    f.country_id{Country.first.try(:id) || FactoryGirl.create(:country).id}
    f.language_id{Language.first.try(:id) || FactoryGirl.create(:language).id}
  end

  factory :adult_patron, :class => 'Patron' do |f|
    f.sequence(:full_name){|n| "adult_#{n}"}
    f.patron_type_id{PatronType.find_by_name('Person').id}
    f.country_id{Country.first.id || FactoryGirl.create(:country).id}
    f.language_id{Language.first.id || FactoryGirl.create(:language).id}
    f.date_of_birth DateTime.parse("#{DateTime.now.year-25}0101")
  end

  factory :student_patron, :class => 'Patron' do |f|
    f.sequence(:full_name){|n| "student_#{n}"}
    f.patron_type_id{PatronType.find_by_name('Person').id}
    f.country_id{Country.first.id || FactoryGirl.create(:country).id}
    f.language_id{Language.first.id || FactoryGirl.create(:language).id}
    f.date_of_birth{DateTime.parse("#{DateTime.now.year-16}0101")}
  end

  factory :juniors_patron, :class => 'Patron' do |f|
    f.sequence(:full_name){|n| "juniors_#{n}"}
    f.patron_type_id{PatronType.find_by_name('Person').id}
    f.country_id{Country.first.id || FactoryGirl.create(:country).id}
    f.language_id{Language.first.id || FactoryGirl.create(:language).id}
    f.date_of_birth{DateTime.parse("#{DateTime.now.year-13}0101")}
  end

  factory :elements_patron, :class => 'Patron' do |f|
    f.sequence(:full_name){|n| "elements_#{n}"}
    f.patron_type_id{PatronType.find_by_name('Person').id}
    f.country_id{Country.first.id || FactoryGirl.create(:country).id}
    f.language_id{Language.first.id || FactoryGirl.create(:language).id}
    f.date_of_birth{DateTime.parse("#{DateTime.now.year-7}0101")}
  end

  factory :children_patron, :class => 'Patron' do |f|
    f.sequence(:full_name){|n| "children_#{n}"}
    f.patron_type_id{PatronType.find_by_name('Person').id}
    f.country_id{Country.first.id || FactoryGirl.create(:country).id}
    f.language_id{Language.first.id || FactoryGirl.create(:language).id}
    f.date_of_birth{DateTime.parse("#{DateTime.now.year-2}0101")}
  end
  
end

FactoryGirl.define do
  factory :invalid_patron, :class => 'Patron' do |f|
  end
end
