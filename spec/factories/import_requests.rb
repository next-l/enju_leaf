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
#  id               :bigint           not null, primary key
#  isbn             :string
#  manifestation_id :bigint
#  user_id          :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
