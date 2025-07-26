FactoryBot.define do
  factory :purchase_request do |f|
    f.sequence(:title) {|n| "purchase_request_#{n}"}
    f.user_id {FactoryBot.create(:user).id}
  end
end

# == Schema Information
#
# Table name: purchase_requests
#
#  id                  :bigint           not null, primary key
#  accepted_at         :datetime
#  author              :text
#  date_of_publication :datetime
#  denied_at           :datetime
#  isbn                :string
#  note                :text
#  price               :integer
#  pub_date            :string
#  publisher           :text
#  state               :string
#  title               :text             not null
#  url                 :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  user_id             :bigint           not null
#
# Indexes
#
#  index_purchase_requests_on_state    (state)
#  index_purchase_requests_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
