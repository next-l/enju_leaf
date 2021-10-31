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
describe EnjuManifestationViewer::ApplicationHelper do
  fixtures :all

  it "should render google_books preview template" do
    helper.google_book_search_preview(manifestations(:manifestation_00001).identifier_contents(:isbn).first).should =~ /<div id='google_book_search_content'>/
  end

  it "should render youtube template" do
    helper.embed_content(manifestations(:manifestation_00022)).should =~ /frameborder="0" gesture="media" allow="encrypted-media" allowfullscreen/
  end

  it "should render nicovideo template" do
    helper.embed_content(manifestations(:manifestation_00023)).should =~ /<script type="application\/javascript" src="https:\/\/embed.nicovideo.jp\/watch\//
  end

  it "should render flickr template" do
    helper.embed_content(manifestations(:manifestation_00218)).should =~ /<object width="400" height="300"><param name="flashvars"/
  end

  #it "should render scribd template" do
  #  helper.embed_content(manifestations(:manifestation_00001)).should =~ /<td colspan="2" style="width: 700px">/
  #end
end
