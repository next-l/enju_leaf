class MessageTemplate < ActiveRecord::Base
  has_many :message_requests

  validates_uniqueness_of :status
  validates_presence_of :status, :title, :body

  acts_as_list

  def self.per_page
    10
  end

  def embed_body(options = {})
    template = Erubis::Eruby.new(body)
    context = {
      :library_group => LibraryGroup.site_config
    }.merge(options)
    template.evaluate(context)
  end

  def self.localized_template(status, locale)
    MessageTemplate.first(:conditions => {:status => status, :locale => locale}) || MessageTemplate.first(:conditions => {:status => status})
  end
end
