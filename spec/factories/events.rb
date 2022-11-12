FactoryBot.define do
  factory :event do |f|
    f.sequence(:name){|n| "event_#{n}"}
    f.start_at{Time.zone.now}
    f.end_at{1.hour.from_now}
    f.library_id{FactoryBot.create(:library).id}
    f.event_category_id{FactoryBot.create(:event_category).id}
  end
end

# == Schema Information
#
# Table name: events
#
#  id                :integer          not null, primary key
#  library_id        :integer          not null
#  event_category_id :integer          not null
#  name              :string           not null
#  note              :text
#  start_at          :datetime
#  end_at            :datetime
#  all_day           :boolean          default(FALSE), not null
#  display_name      :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  place_id          :integer
#
