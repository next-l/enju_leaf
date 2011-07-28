class EventCategory < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  has_many :events

  def self.per_page
    10
  end
end

# == Schema Information
#
# Table name: event_categories
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#

