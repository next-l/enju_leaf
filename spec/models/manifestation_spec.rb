require 'rails_helper'

describe Manifestation, solr: true do
  fixtures :all
  before(:context) do
    Manifestation.reindex
  end

  context "search" do
    it "should set year_of_publication" do
      manifestation = FactoryBot.create(:manifestation, pub_date: '2000')
      manifestation.year_of_publication.should eq 2000
      manifestation.date_of_publication.should eq Time.zone.parse('2000-01-01')
    end

    it "should set date_of_publication" do
      manifestation = FactoryBot.create(:manifestation, pub_date: '2000-01')
      manifestation.year_of_publication.should eq 2000
      manifestation.month_of_publication.should eq 1
      manifestation.date_of_publication.should eq Time.zone.parse('2000-01-01')
    end

    it "should set volume_number" do
      manifestation = FactoryBot.create(:manifestation, volume_number_string: '第1巻', issue_number_string: '20号分冊1', edition_string: '第3版')
      manifestation.volume_number.should eq 1
      manifestation.issue_number.should eq 20
      manifestation.edition.should eq 3
    end

    it "should search title in openurl" do
      openurl = Openurl.new({ title: "プログラミング" })
      results = openurl.search
      openurl.query_text.should eq "btitle_text:プログラミング"
      results.size.should eq 8
      openurl = Openurl.new({ jtitle: "テスト" })
      results = openurl.search
      results.size.should eq 3
      openurl.query_text.should eq "jtitle_text:テスト"
      openurl = Openurl.new({ atitle: "2005" })
      results = openurl.search
      results.size.should eq 1
      openurl.query_text.should eq "atitle_text:2005"
      openurl = Openurl.new({ atitle: "テスト", jtitle: "テスト雑誌" })
      results = openurl.search
      results.size.should eq 2
    end

    it "should search agent in openurl" do
      openurl = Openurl.new({ aulast: "Administrator" })
      results = openurl.search
      openurl.query_text.should eq "au_text:Administrator"
      results.size.should eq 2
      openurl = Openurl.new({ aufirst: "名称" })
      results = openurl.search
      openurl.query_text.should eq "au_text:名称"
      results.size.should eq 1
      openurl = Openurl.new({ au: "テスト" })
      results = openurl.search
      openurl.query_text.should eq "au_text:テスト"
      results.size.should eq 1
      openurl = Openurl.new({ pub: "Administrator" })
      results = openurl.search
      openurl.query_text.should eq "publisher_text:Administrator"
      results.size.should eq 4
    end

    it "should search isbn in openurl" do
      openurl = Openurl.new({ api: "openurl", isbn: "4798" })
      results = openurl.search
      openurl.query_text.should eq "isbn_sm:4798*"
      results.size.should eq 2
    end

    it "should search issn in openurl" do
      openurl = Openurl.new({ api: "openurl", issn: "0913" })
      results = openurl.search
      openurl.query_text.should eq "issn_sm:0913*"
      results.size.should eq 1
    end

    it "should search any in openurl" do
      openurl = Openurl.new({ any: "テスト" })
      results = openurl.search
      results.size.should eq 9
    end

    it "should search multi in openurl" do
      openurl = Openurl.new({ btitle: "CGI Perl プログラミング" })
      results = openurl.search
      results.size.should eq 3
      openurl = Openurl.new({ jtitle: "テスト", pub: "テスト" })
      results = openurl.search
      results.size.should eq 2
    end

    it "shoulld get search_error in openurl" do
      lambda {Openurl.new({ isbn: "12345678901234" })}.should raise_error(OpenurlQuerySyntaxError)
      lambda {Openurl.new({ issn: "1234abcd" })}.should raise_error(OpenurlQuerySyntaxError)
      lambda {Openurl.new({ aufirst: "テスト 名称" })}.should raise_error(OpenurlQuerySyntaxError)
    end

    it "should_get_number_of_pages" do
      manifestations(:manifestation_00001).number_of_pages.should eq 100
    end

    it "should have parent_of_series" do
      manifestations(:manifestation_00001).parent_of_series.should be_truthy
    end

    it "should respond to extract_text" do
      manifestations(:manifestation_00001).extract_text.should be_nil
    end

    it "should respond to title" do
      manifestations(:manifestation_00001).title.should be_truthy
    end

    it "should respond to pickup" do
      lambda {Manifestation.pickup}.should_not raise_error # (ActiveRecord::RecordNotFound)
    end

    it "should be periodical if its series_statement is periodical" do
      manifestations(:manifestation_00202).serial?.should be_truthy
    end

    it "should validate access_address" do
      manifestation = manifestations(:manifestation_00202)
      manifestation.access_address = 'http:/www.example.jp'
      manifestation.should_not be_valid
    end

    it "should search custom identifiers" do
      Manifestation.search do
        fulltext 'identifier_text:custom1111'
      end.results.count.should eq 1
    end

    # it "should set series_statement if the manifestation is periodical" do
    #  manifestation = series_statements(:two).manifestations.new
    #  manifestation.set_series_statements([series_statements(:two)])
    #  #manifestation.original_title.should eq 'テスト雑誌２月号'
    #  #manifestation.serial_number.should eq 3
    #  #manifestation.issue_number.should eq 3
    #  #manifestation.volume_number.should eq 1
    # end
  end

  context ".export" do
    it "should export a header line" do
      lines = Manifestation.export
      csv = CSV.parse(lines, headers: true, col_sep: "\t")
      csv["manifestation_id"].compact.should_not be_empty
      csv["manifestation_identifier"].compact.should_not be_empty
      csv["manifestation_created_at"].compact.should_not be_empty
      csv["manifestation_updated_at"].compact.should_not be_empty
      csv["item_id"].compact.should_not be_empty
      csv["item_created_at"].compact.should_not be_empty
      csv["item_updated_at"].compact.should_not be_empty
      csv["subject:unknown"].compact.inject(0) {|count, a| count += 1 if a == 'next-l'; count}.should eq manifestations(:manifestation_00001).items.count
      csv["classification:ndc9"].compact.inject(0) {|count, a| count += 1 if a == '400'; count}.should eq manifestations(:manifestation_00001).items.count
      csv["extent"].compact.should_not be_empty
      csv["dimensions"].compact.should_not be_empty
      expect(csv["manifestation_memo"].compact).to be_empty
      expect(csv["item_memo"].compact).to be_empty
      expect(csv["manifestation_price"].compact.first).to eq "1980"
      expect(csv["item_price"].compact.first).to eq nil
      expect(csv["library"].compact.first).to eq "web"
      expect(csv["shelf"].compact.first).to eq "web"
      expect(csv["jpno"].compact).not_to be_empty
      expect(csv["ncid"].compact).not_to be_empty
      expect(csv["lccn"].compact).not_to be_empty
      # expect(csv["doi"].compact).not_to be_empty
      expect(csv["identifier:jpno"].compact).to be_empty
      expect(csv["identifier:ncid"].compact).to be_empty
      expect(csv["identifier:lccn"].compact).to be_empty
    end

    it "should export edition fields" do
      manifestation = FactoryBot.create(:manifestation, edition: 2, edition_string: "Revised Ed.")
      lines = Manifestation.export
      csv = CSV.parse(lines, headers: true, col_sep: "\t")
      expect(csv["edition"].compact).not_to be_empty
      expect(csv["edition_string"].compact).not_to be_empty
      m = csv.find {|row| row["manifestation_id"].to_i == manifestation.id }
      expect(m["edition"]).to eq "2"
      expect(m["edition_string"]).to eq "Revised Ed."
    end

    it "should export title_transcription fields" do
      manifestation = FactoryBot.create(:manifestation, title_transcription: "Transcripted title")
      lines = Manifestation.export
      csv = CSV.parse(lines, headers: true, col_sep: "\t")
      expect(csv["title_transcription"].compact).not_to be_empty
      m = csv.find {|row| row["manifestation_id"].to_i == manifestation.id }
      expect(m["title_transcription"]).to eq "Transcripted title"
    end

    it "should export volume fields" do
      manifestation = FactoryBot.create(:manifestation, volume_number: 15, volume_number_string: "Vol.15")
      lines = Manifestation.export
      csv = CSV.parse(lines, headers: true, col_sep: "\t")
      expect(csv["volume_number"].compact).not_to be_empty
      expect(csv["volume_number_string"].compact).not_to be_empty
      m = csv.find {|row| row["manifestation_id"].to_i == manifestation.id }
      expect(m["volume_number"]).to eq "15"
      expect(m["volume_number_string"]).to eq "Vol.15"
    end

    it "should export multiple identifiers" do
      manifestation = FactoryBot.create(:manifestation)
      manifestation.isbn_records.create(body: "978-4043898039")
      manifestation.isbn_records.create(body: "978-4840239219")
      lines = Manifestation.export()
      csv = CSV.parse(lines, headers: true, col_sep: "\t")
      m = csv.find {|row| row["manifestation_id"].to_i == manifestation.id }
      expect(m["isbn"].split('//').sort).to eq [ '9784043898039', '9784840239219' ]
      expect(m["identifier:isbn"]).to be_nil
    end

    it "should respect the role of the user" do
      FactoryBot.create(:item, bookstore_id: 1, price: 100, budget_type_id: 1)
      lines = Manifestation.export(role: 'Guest')
      csv = CSV.parse(lines, headers: true, col_sep: "\t")
      expect(csv["bookstore"].compact).to be_empty
      expect(csv["item_price"].compact).to be_empty
      expect(csv["budget_type"].compact).to be_empty

      lines = Manifestation.export(role: 'Librarian')
      csv = CSV.parse(lines, headers: true, col_sep: "\t")
      expect(csv["bookstore"].compact).not_to be_empty
      expect(csv["item_price"].compact).not_to be_empty
      expect(csv["budget_type"].compact).not_to be_empty
    end

    it 'should escape LF/CR to "\n"' do
      manifestation = FactoryBot.create(:manifestation,
        abstract: "test\ntest",
        description: "test\ntest",
        note: "test\ntest"
      )
      item = FactoryBot.create(:item, manifestation: manifestation, note: "test\ntest")
      lines = Manifestation.export
      csv = CSV.parse(lines, headers: true, col_sep: "\t")
      expect(csv["abstract"].compact).not_to be_empty
      expect(csv["description"].compact).not_to be_empty
      expect(csv["note"].compact).not_to be_empty
      expect(csv["item_note"].compact).not_to be_empty
      m = csv.find {|row| row["manifestation_id"].to_i == manifestation.id }
      expect(m["description"]).to eq "test\ntest"
      expect(m["abstract"]).to eq "test\ntest"
      expect(m["note"]).to eq "test\ntest"
      expect(m["item_note"]).to eq "test\ntest"
    end

    it 'should export custom properties"' do
      item = FactoryBot.create(:item)
      item.item_custom_values << FactoryBot.build(:item_custom_value)
      item.manifestation.manifestation_custom_values << FactoryBot.build(:manifestation_custom_value)
      lines = Manifestation.export(role: 'Librarian')
      csv = CSV.parse(lines, headers: true, col_sep: "\t")
      m = csv.find {|row| row["manifestation_id"].to_i == item.manifestation.id }
      item.item_custom_values.each do |custom_value|
        expect(m["item:#{custom_value.item_custom_property.name}"]).to eq custom_value.value
      end
      item.manifestation.manifestation_custom_values.each do |custom_value|
        expect(m["manifestation:#{custom_value.manifestation_custom_property.name}"]).to eq custom_value.value
      end
    end

    it 'should respond to reservable?' do
      expect(manifestations(:manifestation_00001).reservable?).to be_truthy
      expect(manifestations(:manifestation_00101).reservable?).to be_falsy
    end
  end

  it 'should extract fulltext' do
    manifestation = FactoryBot.create(:manifestation)
    manifestation.attachment.attach(io: File.open("spec/fixtures/files/resource_import_file_sample1.tsv"), filename: 'sample.txt')
    expect(manifestation.extract_text).to match(/資料ID/)
  end
end

# == Schema Information
#
# Table name: manifestations
#
#  id                              :bigint           not null, primary key
#  abstract                        :text
#  access_address                  :string
#  available_at                    :datetime
#  classification_number           :string
#  date_accepted                   :datetime
#  date_captured                   :datetime
#  date_copyrighted                :datetime
#  date_of_publication             :datetime
#  date_submitted                  :datetime
#  depth                           :integer
#  description                     :text
#  dimensions                      :text
#  edition                         :integer
#  edition_string                  :string
#  end_page                        :integer
#  extent                          :text
#  fulltext                        :text
#  fulltext_content                :boolean
#  height                          :integer
#  issue_number                    :integer
#  issue_number_string             :string
#  lock_version                    :integer          default(0), not null
#  manifestation_identifier        :string
#  memo                            :text
#  month_of_publication            :integer
#  note                            :text
#  original_title                  :text             not null
#  price                           :integer
#  pub_date                        :string
#  publication_place               :text
#  repository_content              :boolean          default(FALSE), not null
#  required_score                  :integer          default(0), not null
#  serial                          :boolean
#  serial_number                   :integer
#  serial_number_string            :string
#  start_page                      :integer
#  statement_of_responsibility     :text
#  subscription_master             :boolean          default(FALSE), not null
#  title_alternative               :text
#  title_alternative_transcription :text
#  title_transcription             :text
#  valid_until                     :datetime
#  volume_number                   :integer
#  volume_number_string            :string
#  width                           :integer
#  year_of_publication             :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  carrier_type_id                 :bigint           default(1), not null
#  content_type_id                 :bigint           default(1)
#  frequency_id                    :bigint           default(1), not null
#  language_id                     :bigint           default(1), not null
#  nii_type_id                     :bigint
#  required_role_id                :bigint           default(1), not null
#
# Indexes
#
#  index_manifestations_on_access_address            (access_address)
#  index_manifestations_on_date_of_publication       (date_of_publication)
#  index_manifestations_on_manifestation_identifier  (manifestation_identifier)
#  index_manifestations_on_nii_type_id               (nii_type_id)
#  index_manifestations_on_updated_at                (updated_at)
#
# Foreign Keys
#
#  fk_rails_...  (required_role_id => roles.id)
#
