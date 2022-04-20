require "rails_helper"

RSpec.describe ReserveMailer, type: :mailer do
  fixtures :all

  it "should send accepted mail" do
    mailer = ReserveMailer.accepted(reserves(:reserve_00001))
    expect(mailer.body).to match(/^えんじゅ図書館\r\n/)
  end

  it "should send expired mail" do
    mailer = ReserveMailer.expired(reserves(:reserve_00001))
    expect(mailer.body).to match(/^えんじゅ図書館\r\n/)
  end
end
