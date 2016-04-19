class Name < ActiveRecord::Base
  belongs_to :manifestation
  belongs_to :profile
  validates :source, presence: true

  acts_as_list scope: :profile_id
end
