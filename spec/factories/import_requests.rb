FactoryBot.define do
  factory :import_request do
    sequence(:isbn) {|n| "isbn_#{n}"}
    association :user, factory: :librarian
  end
end

# == Schema Information
#
# Table name: import_requests
#
#  id               :bigint           not null, primary key
#  isbn             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  manifestation_id :bigint
#  user_id          :bigint
#
# Indexes
#
#  index_import_requests_on_isbn              (isbn)
#  index_import_requests_on_manifestation_id  (manifestation_id)
#  index_import_requests_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
