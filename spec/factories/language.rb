FactoryGirl.define do
  factory :language do |f|
    f.sequence(:name){|n| "language_#{n}"}
    f.sequence(:iso_639_1){|n| "639_1_#{n}"}
    f.sequence(:iso_639_2){|n| "639_2_#{n}"}
    f.sequence(:iso_639_3){|n| "639_3_#{n}"}
  end
end
