class MessageTemplate < ActiveRecord::Base
  default_scope :order => "position"
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
    MessageTemplate.where(:status => status, :locale => locale).first || MessageTemplate.where(:status => status).first
  end
end



# == Schema Information
#
# Table name: message_templates
#
#  id         :integer         not null, primary key
#  status     :string(255)     not null
#  title      :text            not null
#  body       :text            not null
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#  locale     :string(255)     default("ja")
#

