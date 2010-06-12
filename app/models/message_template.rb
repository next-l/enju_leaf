class MessageTemplate < ActiveRecord::Base
  has_many :message_requests

  validates_uniqueness_of :status
  validates_presence_of :status, :title, :body

  acts_as_list

  def self.per_page
    10
  end
end
