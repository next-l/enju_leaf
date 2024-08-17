FactoryBot.define do
  factory :carrier_type do |f|
    f.sequence(:name){|n| "carrier_type_#{n}"}
  end
end

# == Schema Information
#
# Table name: carrier_types
#
#  id                      :bigint           not null, primary key
#  name                    :string           not null
#  display_name            :text
#  note                    :text
#  position                :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  attachment_file_name    :string
#  attachment_content_type :string
#  attachment_file_size    :bigint
#  attachment_updated_at   :datetime
#
