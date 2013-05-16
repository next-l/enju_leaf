FactoryGirl.define do
  factory :library, :class => 'Library' do |f|
    f.sequence(:name){|n| "library#{n}"}
    f.sequence(:short_display_name){|n| "library_#{n}"}
    f.library_group_id{FactoryGirl.create(:library_group).id}
  end

  factory :libraryA, :class => 'Library' do |f|
    f.name {"liba"}
    f.short_display_name{"libraryA"}
    f.library_group_id{FactoryGirl.create(:library_group).id}
  end

  factory :libraryB, :class => 'Library' do |f|
    f.name {"libb"}
    f.short_display_name{"libraryB"}
    f.library_group_id{FactoryGirl.create(:library_group).id}
  end
end

FactoryGirl.define do
  factory :invalid_library, :class => 'Library' do |f|
    f.library_group_id{FactoryGirl.create(:library_group)}
  end
end
