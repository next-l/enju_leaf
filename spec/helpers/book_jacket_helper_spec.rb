require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the PatronsHelper. For example:
#
# describe PatronsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe EnjuManifestationViewer::BookJacketHelper do
  fixtures :all

  it "should get screenshot", :vcr => true do
    helper.screenshot_tag(manifestations(:manifestation_00003)).should =~ /<a href=\"http:\/\/www.slis.keio.ac.jp\/\">/
  end

  it "should get book jacket" do
    helper.book_jacket_tag(manifestations(:manifestation_00001)).should =~ /<div id=\"gbsthumbnail1\" class=\"book_jacket\"><\/div>/
  end

  it "should generate a link to Amazon" do
    helper.amazon_link(manifestations(:manifestation_00001).isbn_records.first.body).should =~ /https:\/\/www.amazon.co.jp\/dp\/4798002062/
  end

  it "should get honmoto.com book jacket" do
    html = helper.book_jacket_tag(manifestations(:manifestation_00001), "hanmotocom")
    expect(html).to have_selector 'img[src="https://www.hanmoto.com/bd/img/9784798002064.jpg"]'
  end

  it "should get openbd book jacket" do
    helper.book_jacket_tag(manifestations(:manifestation_00001), "openbd").should =~ /<div id=\"openbd_thumbnail1\" class=\"book_jacket\"><\/div>/
  end
end
