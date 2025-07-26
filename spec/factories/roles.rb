FactoryBot.define do
  factory :role, class: Role do |f|
    f.sequence(:name) do |n|
      idx = "a"
      n.times { idx = idx.next }
      "name#{idx}"
    end
  end
end

# == Schema Information
#
# Table name: roles
#
#  id           :bigint           not null, primary key
#  display_name :string
#  name         :string           not null
#  note         :text
#  position     :integer
#  score        :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_roles_on_lower_name  (lower((name)::text)) UNIQUE
#
