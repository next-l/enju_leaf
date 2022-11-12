class EventCategory < ApplicationRecord
  # include MasterModel
  validates :name, presence: true
  acts_as_list
  default_scope { order('position') }
  has_many :events, dependent: :restrict_with_exception

  paginates_per 10
end

# == Schema Information
#
# Table name: event_categories
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
