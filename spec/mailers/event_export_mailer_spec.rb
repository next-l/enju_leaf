require "rails_helper"

RSpec.describe EventExportMailer, type: :mailer do
  fixtures :all

  it "should send completed mail" do
    mailer = EventExportMailer.completed(event_export_files(:event_export_file_00001))
    expect(mailer.body.to_s).to match(/^Enju Library\n/)
  end
end
