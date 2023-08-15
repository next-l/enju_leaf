require 'rails_helper'

describe Event do
  fixtures :events

  it "should set_all_day" do
    event = events(:event_00001)
    event.all_day = true
    event.set_all_day
    event.all_day.should be_truthy
  end

  it "should set all_day and beginning_of_day" do
    event = events(:event_00008)
    event.all_day = true
    event.set_all_day
    event.start_at.should eq event.end_at.beginning_of_day
  end

  it "should export events" do
    lines = Event.export
    CSV.parse(lines, col_sep: "\t")
    expect(lines).not_to be_empty
    expect(lines.split(/\n/).size).to eq Event.all.count + 1
  end
end

# == Schema Information
#
# Table name: events
#
#  id                        :bigint           not null, primary key
#  library_id                :bigint           not null
#  event_category_id         :bigint           not null
#  name                      :string           not null
#  note                      :text
#  start_at                  :datetime
#  end_at                    :datetime
#  all_day                   :boolean          default(FALSE), not null
#  display_name              :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  place_id                  :bigint
#  display_name_translations :jsonb            not null
#
