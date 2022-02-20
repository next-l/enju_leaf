class MessageTemplate < ApplicationRecord
  has_many :message_requests, dependent: :destroy

  validates :status, uniqueness: true
  validates :status, :title, :body, presence: true

  acts_as_list

  paginates_per 10

  def embed_body(options = {})
    template = Erubis::Eruby.new(body)
    context = {
      library_group: LibraryGroup.site_config
    }.merge(options)
    template.evaluate(context)
  end

  def self.localized_template(status, locale)
    MessageTemplate.find_by(status: status, locale: locale) || MessageTemplate.find_by(status: status)
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
