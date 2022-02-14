class LendingPolicy < ApplicationRecord
  default_scope { order('lending_policies.position') }
  belongs_to :item
  belongs_to :user_group

  validates :user_group_id, uniqueness: { scope: :item_id }
  validates_date :fixed_due_date, allow_blank: true

  paginates_per 10

  acts_as_list scope: :item_id
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
