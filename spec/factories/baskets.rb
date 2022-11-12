FactoryBot.define do
  factory :basket do |f|
    f.user_id{FactoryBot.create(:user).id}
  end
end

# == Schema Information
#
# Table name: baskets
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  note         :text
#  lock_version :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
