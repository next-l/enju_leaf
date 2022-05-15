require 'rails_helper'

describe ManifestationsHelper do
  fixtures :all

  it "should get paginate_id_link" do
    helper.paginate_id_link(manifestations(:manifestation_00003), [1, 2, 3]).should =~ /Next <a href=\"\/manifestations\/2\">Previous<\/a>/
  end
end
