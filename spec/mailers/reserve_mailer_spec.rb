require "rails_helper"

RSpec.describe ReserveMailer, type: :mailer do
  fixtures :all

  it "should send accepted mail" do
    mailer = ReserveMailer.accepted(reserves(:reserve_00001))
    expect(mailer.body.to_s).to match(/^Enju Library\n/)
  end

  it "should send expired mail" do
    mailer = ReserveMailer.expired(reserves(:reserve_00001))
    expect(mailer.body.to_s).to match(/^Enju Library\n/)
  end
end
