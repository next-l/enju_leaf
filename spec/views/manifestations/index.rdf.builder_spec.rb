require "rails_helper.rb"

describe "manifestations/index.rdf.builder" do
  before(:each) do
    manifestation = FactoryBot.create(:manifestation)
    @manifestations = assign(:manifestations, [manifestation] )
    @library_group = LibraryGroup.first
  end

  it "should export RDF format" do
    params[:format] = "rdf"
    render
    doc = Nokogiri::XML(rendered)
    nodes = doc.css('item')
    expect(nodes).not_to be_empty
    nodes.each do |node|
      rdf_ns = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      expect(node.attribute_with_ns("about", rdf_ns).value).not_to be_empty
    end
  end
end

