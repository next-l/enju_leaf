class BookmarkStatTransition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition


  belongs_to :bookmark_stat, inverse_of: :bookmark_stat_transitions
end

# == Schema Information
#
# Table name: bookmark_stat_transitions
#
#  id               :bigint           not null, primary key
#  to_state         :string
#  metadata         :text             default({})
#  sort_key         :integer
#  bookmark_stat_id :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  most_recent      :boolean          not null
#
