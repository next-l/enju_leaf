require "rails_helper"

RSpec.describe UserExportMailer, type: :mailer do
  fixtures :all

  it "should send completed mail" do
    mailer = UserExportMailer.completed(user_export_files(:user_export_file_00001))
    expect(mailer.body.to_s).to match(/^Enju Library\n/)
  end
end
