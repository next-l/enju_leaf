require 'rails_helper'

describe ManifestationReserveStat do
  fixtures :manifestation_reserve_stats

  it "calculates manifestation count" do
    old_message_count = Message.count
    manifestation_reserve_stats(:one).transition_to!(:started).should be_truthy
    Message.count.should eq old_message_count + 1
    Message.order(:id).last.subject.should eq '[Enju Library] 集計が完了しました'
  end

  it "should calculate in background" do
    ManifestationReserveStatJob.perform_later(manifestation_reserve_stats(:one)).should be_truthy
  end
end

# == Schema Information
#
# Table name: manifestation_reserve_stats
#
#  id           :bigint           not null, primary key
#  completed_at :datetime
#  end_date     :datetime
#  note         :text
#  start_date   :datetime
#  started_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_manifestation_reserve_stats_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
