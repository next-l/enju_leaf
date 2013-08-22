# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :terminal, :class => 'EnjuTerminal' do
    ipaddr "127.0.0.1"
    name "MyString"
    comment "MyString"
    checkouts_autoprint false
    reserve_autoprint false
    manifestation_autoprint false
  end
end
