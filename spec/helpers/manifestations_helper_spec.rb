require 'rails_helper'

describe ManifestationsHelper do
  fixtures :all

  it "should get paginate_id_link" do
    helper.paginate_id_link(manifestations(:manifestation_00003), [1, 2, 3]).should =~ /Next <a href=\"\/manifestations\/2\">Previous<\/a>/
  end

  it 'should export rdf_statement"' do
    expect(rdf_statement(manifestations(:manifestation_00001)).last.to_s).to eq 'よくわかる最新Webサービス技術の基本と仕組み : 標準Webシステム技術とeコマース基盤技術入門'
  end
end
