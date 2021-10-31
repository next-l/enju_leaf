FactoryBot.define do
  factory :message_template do |f|
    f.sequence(:title){|n| "message_template_#{n}"}
    f.sequence(:status){|n| "message_template_#{n}"}
    f.sequence(:body){|n| "message_template_#{n}"}
  end
end

# == Schema Information
#
# Table name: message_templates
#
#  id         :bigint           not null, primary key
#  status     :string           not null
#  title      :text             not null
#  body       :text             not null
#  position   :integer
#  locale     :string           default("en")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
