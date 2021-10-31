FactoryBot.define do
  factory :role, class: Role do |f|
    f.sequence(:name) do |n|
      idx = "a"
      n.times{ idx = idx.next }
      "name#{idx}"
    end
  end
end

# == Schema Information
#
# Table name: roles
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :string
#  note         :text
#  created_at   :datetime
#  updated_at   :datetime
#  score        :integer          default(0), not null
#  position     :integer
#
