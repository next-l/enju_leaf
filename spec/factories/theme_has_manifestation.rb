# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :theme_has_manifestation, :class => 'ThemeHasManifestation' do
    theme_id 1
    manifestation_id 1
    position 1
  end
end
