module ExportFile
  extend ActiveSupport::Concern

  included do
    belongs_to :user
    validates :user, presence: true
    attr_accessor :mode
  end

  def send_message(mailer)
    sender = User.find(1)
    message = Message.create!(
      recipient: user.username,
      sender: sender,
      body: mailer.body.raw_source,
      subject: mailer.subject
    )
  end
end
