# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reminder_list, :class => 'ReminderList' do
    after(:build) do |x|
      x.checkout = Checkout.first
    end
  end

end
