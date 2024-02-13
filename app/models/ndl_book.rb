class NdlBook
  def initialize(node)
    @node = node
  end

  def jpno
    @node.at('./dc:identifier[@xsi:type="dcndl:JPNO"]').try(:content).to_s
  end

  def permalink
    @node.at('./link').try(:content).to_s
  end

  def itemno
    URI.parse(permalink).path.split('/').last
  end

  def title
    @node.at('./title').try(:content).to_s
  end

  def volume
    @node.at('./dcndl:volume').try(:content).to_s
  end

  def series_title
    @node.at('./dcndl:seriesTitle').try(:content).to_s
  end

  def creator
    @node.xpath('./dc:creator').map(&:content).join(' ')
  end

  def publisher
    @node.xpath('./dc:publisher').map(&:content).join(' ')
  end

  def issued
    @node.at('./dcterms:issued[@xsi:type="dcterms:W3CDTF"]').try(:content).to_s
  end

  def isbn
    @node.at('./dc:identifier[@xsi:type="dcndl:ISBN"]').try(:content).to_s
  end

  def self.per_page
    10
  end

  def self.search(query, page = 1, _per_page = per_page)
    if query
      cnt = per_page
      page = 1 if page.to_i < 1
      idx = (page.to_i - 1) * cnt + 1
      doc = Nokogiri::XML(Manifestation.search_ndl(query, cnt: cnt, page: page, idx: idx, raw: true, mediatype: 'books periodicals').to_s)
      items = doc.xpath('//channel/item').map{|node| new node }
      total_entries = doc.at('//channel/openSearch:totalResults').content.to_i

      {items: items, total_entries: total_entries}
    else
      {items: [], total_entries: 0}
    end
  end

  def self.import_from_sru_response(itemno)
    identifier = NdlBibIdRecord.find_by(body: itemno)
    return if identifier

    url = "https://ndlsearch.ndl.go.jp/api/sru?operation=searchRetrieve&recordSchema=dcndl&maximumRecords=1&query=%28itemno=#{itemno}%29&onlyBib=true"
    xml = Faraday.get(url).body
    response = Nokogiri::XML(xml).at('//xmlns:recordData')
    return unless response.try(:content)

    Manifestation.import_record(Nokogiri::XML(response.content))
  end

  def subjects
    @node.xpath('//dcterms:subject/rdf:Description').map{|a|
      {
        id: a.attributes['about'].content,
        value: a.at('./rdf:value').content
      }
    }
  end

  def authors
    @node.xpath('//dcterms:creator/foaf:Agent').map{|a| {id: a.attributes['about'].content, name: a.at('./foaf:name').content, transcription: a.at('./dcndl:transcription').try(:content)}}
  end

  attr_accessor :url

  class AlreadyImported < StandardError
  end
end
