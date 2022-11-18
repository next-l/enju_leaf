class ReserveStatHasUser < ApplicationRecord
  belongs_to :user_reserve_stat
  belongs_to :user

  validates :user_id, uniqueness: { scope: :user_reserve_stat_id }

  paginates_per 10
end

# == Schema Information
#
# Table name: reserve_stat_has_users
#
#  id                   :bigint           not null, primary key
#  user_reserve_stat_id :integer          not null
#  user_id              :bigint           not null
#  reserves_count       :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
