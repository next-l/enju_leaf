FactoryBot.define do
  factory :import_request do
    sequence(:isbn){|n| "isbn_#{n}"}
    association :user, factory: :librarian
  end
end

# == Schema Information
#
# Table name: import_requests
#
#  id               :integer          not null, primary key
#  isbn             :string
#  manifestation_id :integer
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#
