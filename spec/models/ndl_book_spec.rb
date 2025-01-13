require 'rails_helper'

describe NdlBook do
  fixtures :all

  it "should respond to per_page" do
    NdlBook.per_page.should eq 10
  end

  context 'search' do
    it 'should search bibliographic record', vcr: true do
      NdlBook.search('library system')[:total_entries].should eq 2282
    end

    it "should not distinguish double byte space from one-byte space in a query", vcr: true do
      NdlBook.search("カミュ ペスト")[:total_entries].should eq NdlBook.search("カミュ　ペスト")[:total_entries]
    end
  end

  context "import" do
    it "should import bibliographic record", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000010980901')
      manifestation.manifestation_identifier.should eq 'https://ndlsearch.ndl.go.jp/books/R100000002-I000010980901'
      manifestation.identifier_contents(:isbn).should eq ['9784839931995']
      manifestation.classifications.pluck(:category).should eq ["007.64"]
      manifestation.identifier_contents(:iss_itemno).should eq ["R100000002-I000010980901"]
      manifestation.identifier_contents(:jpno).should eq ["21816393"]
      manifestation.language.name.should eq "Japanese"
      manifestation.creators.first.full_name.should eq '秋葉, 拓哉'
      manifestation.creators.first.full_name_transcription.should eq 'アキバ, タクヤ'
      manifestation.creators.first.agent_identifier.should eq 'http://id.ndl.go.jp/auth/entity/01208840'
      manifestation.price.should eq 3280
      manifestation.start_page.should eq 1
      manifestation.end_page.should eq 315
      manifestation.height.should eq 24.0
      manifestation.subjects.size.should eq 1
      manifestation.subjects.first.subject_heading_type.name.should eq 'ndlsh'
      manifestation.subjects.first.term.should eq 'プログラミング (コンピュータ)'
      manifestation.classifications.first.category.should eq '007.64'
      manifestation.statement_of_responsibility.should eq '秋葉拓哉, 岩田陽一, 北川宜稔 著; Usu-ya 編'
      manifestation.extent.should eq "315p"
      manifestation.dimensions.should eq "24cm"
    end

    it "should import bibliographic record that does not have any classifications", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000003641700')
      manifestation.original_title.should eq "アンパンマンとどうぶつえん"
      manifestation.title_transcription.should eq "アンパンマン ト ドウブツエン"
    end

    it "should import volume_number_string", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000011037191')
      manifestation.volume_number_string.should eq '上'
    end

    it "should import title_alternative", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000010926074')
      manifestation.title_alternative.should eq 'PLATINADATA'
      manifestation.title_alternative_transcription.should eq 'PLATINA DATA'
    end

    it "should import series_statement", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000004152429')
      manifestation.original_title.should eq "ズッコケ三人組のダイエット講座"
      manifestation.series_statements.first.original_title.should eq "ポプラ社文庫. ズッコケ文庫"
      manifestation.serial.should be_falsy
    end

    it "should import series_statement's creator", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000008369884')
      manifestation.series_statements.first.original_title.should eq "新・図書館学シリーズ"
      manifestation.series_statements.first.creator_string.should eq "高山正也, 植松貞夫 監修"
    end

    it "should import series_statement transctiption", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000011242276')
      manifestation.series_statements.first.original_title.should eq "講談社現代新書"
      manifestation.series_statements.first.title_transcription.should eq "コウダンシャ ゲンダイ シンショ"
    end

    it "should import series_statement if the resource is serial", vcr: true, solr: true do
      manifestation = NdlBook.import_from_sru_response('R100000039-I3377584')
      manifestation.original_title.should eq "週刊新潮"
      manifestation.series_statements.first.original_title.should eq "週刊新潮"
      manifestation.series_statements.first.series_master.should be_truthy
      manifestation.serial.should be_truthy
      manifestation.series_statements.first.root_manifestation.should eq manifestation
      manifestation.root_series_statement.should eq manifestation.series_statements.first
      manifestation.index!

      search = Manifestation.search
      search.build do
        with(:resource_master).equal_to true
        order_by(:created_at, :desc)
      end
      results = search.execute!.results
      expect(results.map(&:original_title).include?("週刊新潮")).to be_truthy
    end

    it "should import pud_date is nil", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000000017951')
      manifestation.original_title.should eq "西日本哲学会会報"
      manifestation.pub_date.should be_nil
    end

    it "should import url contain whitespace", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000002109818')
      manifestation.original_title.should eq 'ザ・スコット・フィッツジェラルド・ブック'
      manifestation.pub_date.should eq '1991'
    end

    it "should import audio cd", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000010273695')
      manifestation.original_title.should eq "劇場版天元突破グレンラガン螺巌篇サウンドトラック・プラス"
      # 2024年の更新でSoundとして返ってくるようになった
      manifestation.manifestation_content_type.name.should eq 'sounds'
    end

    it "should import video dvd", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000009149656')
      manifestation.original_title.should eq "天元突破グレンラガン"
      manifestation.manifestation_content_type.name.should eq 'two_dimensional_moving_image'
    end

    it "should not get volume number if book has not volume", vcr: true do
      NdlBook.search('978-4-04-874013-5')[:items].first.title.should eq "天地明察"
    end

    it "should get volume number", vcr: true do
      NdlBook.search('978-4-04-100292-6')[:items].first.volume.should eq "下"
    end

    it "should not get volume number if book has not volume", vcr: true do
      NdlBook.search('978-4-04-874013-5')[:items].first.volume.should eq ""
    end

    it "should get series title", vcr: true do
      book = NdlBook.search("4840114404")[:items].first
      book.series_title.should eq "マジック・ツリーハウス ; 15"
    end

    it "should not get series title if book has not series title", vcr: true do
      book = NdlBook.search("4788509105")[:items].first
      book.series_title.should eq ""
    end

    it "should import publication_place", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000007725666')
      manifestation.publication_place.should eq "つくば"
    end

    it "should import tactile_text", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000002368034')
      # 2024年の更新でBookとして返ってくるようになった
      # manifestation.manifestation_content_type.name.should eq 'tactile_text'
      manifestation.manifestation_content_type.name.should eq 'text'
    end
    #it "should import computer_program", :vcr => true do
    #  manifestation = NdlBook.import_from_sru_response('R100000002-I000003048761')
    #  manifestation.manifestation_content_type.name.should eq 'computer_program'
    #end
    it "should import map", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I025478296')
      manifestation.manifestation_content_type.name.should eq 'cartographic_image'
    end
    it "should import notated_music", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I025516419')
      manifestation.manifestation_content_type.name.should eq 'notated_music'
    end
    it "should import photograph", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000010677225')
      manifestation.manifestation_content_type.name.should eq 'still_image'
    end
    it "should import painting", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000009199930')
      manifestation.manifestation_content_type.name.should eq 'still_image'
    end
    it "should import picture postcard", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I024847245')
      manifestation.manifestation_content_type.name.should eq 'still_image'
    end
    it "should import still_image", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I024016497')
      manifestation.manifestation_content_type.name.should eq 'still_image'
    end

    it "should import ndc8 classification", vcr: true do
      manifestation = NdlBook.import_from_sru_response("R100000002-I000002467093")
      manifestation.classifications.should_not be_empty
      manifestation.classifications.first.classification_type.name.should eq "ndc8"
      manifestation.classifications.first.category.should eq "547.48"
    end

    it "should import edition", vcr: true do
      manifestation = NdlBook.import_from_sru_response("R100000002-I025107686")
      manifestation.edition_string.should eq "改訂第2版"
    end

    it "should import volume title", vcr: true do
      manifestation = NdlBook.import_from_sru_response("R100000002-I000011225479")
      manifestation.original_title.should eq "じゃらん 関東・東北"
      manifestation.title_transcription.should eq "ジャラン カントウ トウホク"
    end

    it "should import even with invalid url", vcr: true do
      manifestation = NdlBook.import_from_sru_response("R100000002-I000003523406 ")
      expect(manifestation.original_title).to eq "The little boat / written by Kathy Henderson ; illustrated by Patrick Benson."
      expect(manifestation.language.name).to eq "English"
      expect(manifestation.extent).to eq "1 v. (unpaged) : col. ill."
      expect(manifestation.dimensions).to eq "25 x 29 cm."
    end

    it "should import with DDC [Fic]", vcr: true do
      manifestation = NdlBook.import_from_sru_response("R100000002-I000008410444")
      expect(manifestation.original_title).to eq "A single shard / Linda Sue Park."
    end

    it 'should get subject IDs from NDLA', vcr: true do
      itemno = "R100000002-I028087126"
      url = "https://ndlsearch.ndl.go.jp/api/sru?operation=searchRetrieve&recordSchema=dcndl&maximumRecords=1&query=%28itemno=#{itemno}%29&onlyBib=true"
      xml = URI.parse(url).read
      doc = Nokogiri::XML(Nokogiri::XML(xml).at('//xmlns:recordData').content)

      ndl_book = NdlBook.new(doc)
      ndl_book.subjects[0].should eq({id: 'http://id.ndl.go.jp/auth/ndlsh/01058852', value: 'ウェブアプリケーション'})
      ndl_book.subjects[1].should eq({id: 'http://id.ndl.go.jp/auth/ndlsh/00569223', value: 'プログラミング (コンピュータ)'})
    end

    it 'should get author IDs from NDLA', vcr: true do
      itemno = "R100000002-I028087126"
      url = "https://ndlsearch.ndl.go.jp/api/sru?operation=searchRetrieve&recordSchema=dcndl&maximumRecords=1&query=%28itemno=#{itemno}%29&onlyBib=true"
      xml = Faraday.get(url).body
      doc = Nokogiri::XML(Nokogiri::XML(xml).at('//xmlns:recordData').content)

      ndl_book = NdlBook.new(doc)
      ndl_book.authors[0].should eq({id: "http://id.ndl.go.jp/auth/entity/00730574", name: "山田, 祥寛", transcription: "ヤマダ, ヨシヒロ"})
    end
  end
end
