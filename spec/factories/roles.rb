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
#  id           :bigint           not null, primary key
#  name         :string           not null
#  display_name :string
#  note         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  score        :integer          default(0), not null
#  position     :integer
#
