require 'rails_helper'

describe ReserveStatHasUser do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: reserve_stat_has_users
#
#  id                   :bigint           not null, primary key
#  user_reserve_stat_id :bigint           not null
#  user_id              :bigint           not null
#  reserves_count       :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
