require "rails_helper"

RSpec.describe Notifier, type: :mailer do
  fixtures :all

  it "should send message_notification mail" do
    mailer = Notifier.message_notification(messages(:user1_to_user2_1).id)
    expect(mailer.body.to_s).to match(/^Enju Library\n/)
  end

  it "should send manifestation_info mail" do
    mailer = Notifier.manifestation_info(User.first.id, Manifestation.first.id)
    expect(mailer.body.to_s).to match(/^Enju Library\r\n/)
  end
end
