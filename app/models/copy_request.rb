class CopyRequest < ActiveRecord::Base
  attr_accessible :user_id, :body
  belongs_to :user
  validates_presence_of :user
end
