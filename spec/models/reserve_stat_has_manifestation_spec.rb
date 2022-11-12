require 'rails_helper'

describe ReserveStatHasManifestation do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: reserve_stat_has_manifestations
#
#  id                            :bigint           not null, primary key
#  manifestation_reserve_stat_id :integer          not null
#  manifestation_id              :bigint           not null
#  reserves_count                :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
