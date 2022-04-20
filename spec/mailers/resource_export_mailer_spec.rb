require "rails_helper"

RSpec.describe ResourceExportMailer, type: :mailer do
  fixtures :all

  it "should send completed mail" do
    mailer = ResourceExportMailer.completed(resource_export_files(:resource_export_file_00001))
    expect(mailer.body).to match(/^えんじゅ図書館\r\n/)
  end
end
