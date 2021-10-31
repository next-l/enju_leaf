FactoryBot.define do
  factory :lending_policy do |f|
    f.user_group_id{FactoryBot.create(:user_group).id}
    f.item_id{FactoryBot.create(:item).id}
  end
end

# == Schema Information
#
# Table name: lending_policies
#
#  id             :integer          not null, primary key
#  item_id        :integer          not null
#  user_group_id  :integer          not null
#  loan_period    :integer          default(0), not null
#  fixed_due_date :datetime
#  renewal        :integer          default(0), not null
#  fine           :integer          default(0), not null
#  note           :text
#  position       :integer
#  created_at     :datetime
#  updated_at     :datetime
#
