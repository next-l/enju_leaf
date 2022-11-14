require 'rails_helper'

describe UserReserveStat do
  fixtures :user_reserve_stats

  it "calculates user count" do
    old_message_count = Message.count
    user_reserve_stats(:one).transition_to!(:started).should be_truthy
    Message.count.should eq old_message_count + 1
    Message.order(:id).last.subject.should eq '[Enju Library] 集計が完了しました'
  end

  it "should calculate in background" do
    UserReserveStatJob.perform_later(user_reserve_stats(:one)).should be_truthy
  end
end

# == Schema Information
#
# Table name: user_reserve_stats
#
#  id           :bigint           not null, primary key
#  start_date   :datetime
#  end_date     :datetime
#  note         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  started_at   :datetime
#  completed_at :datetime
#  user_id      :bigint
#
