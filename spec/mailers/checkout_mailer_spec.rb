require "rails_helper"

RSpec.describe CheckoutMailer, type: :mailer do
  fixtures :all

  it "should send due_date mail" do
    mailer = CheckoutMailer.due_date(checkouts(:checkout_00001))
    expect(mailer.body).to match(/^えんじゅ図書館\r\n/)
  end

  it "should send overdue mail" do
    mailer = CheckoutMailer.overdue(checkouts(:checkout_00001))
    expect(mailer.body).to match(/^えんじゅ図書館\r\n/)
  end
end
