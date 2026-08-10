require 'rails_helper'

describe NdlBook do
  fixtures :all

  it "should respond to per_page" do
    expect(NdlBook.per_page).to eq 10
  end

  context 'search' do
    it 'should search bibliographic record', vcr: true do
      expect(NdlBook.search('library system')[:total_entries]).to eq 2282
    end

    it "should not distinguish double byte space from one-byte space in a query", vcr: true do
      expect(NdlBook.search("カミュ ペスト")[:total_entries]).to eq NdlBook.search("カミュ　ペスト")[:total_entries]
    end
  end

  context "import" do
    it "should import bibliographic record", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000010980901')
      expect(manifestation.manifestation_identifier).to eq 'https://ndlsearch.ndl.go.jp/books/R100000002-I000010980901'
      expect(manifestation.isbn_records.pluck(:body)).to eq [ '9784839931995' ]
      expect(manifestation.classifications.pluck(:category)).to eq [ "007.64" ]
      expect(manifestation.ndl_bib_id_record.body).to eq "R100000002-I000010980901"
      expect(manifestation.jpno_record.body).to eq "21816393"
      expect(manifestation.language.name).to eq "Japanese"
      expect(manifestation.creators.first.full_name).to eq '秋葉, 拓哉'
      expect(manifestation.creators.first.full_name_transcription).to eq 'アキバ, タクヤ'
      expect(manifestation.creators.first.ndla_record.body).to eq 'http://id.ndl.go.jp/auth/entity/01208840'
      expect(manifestation.price).to eq 3280
      expect(manifestation.start_page).to eq 1
      expect(manifestation.end_page).to eq 315
      expect(manifestation.height).to eq 24.0
      expect(manifestation.subjects.size).to eq 1
      expect(manifestation.subjects.first.subject_heading_type.name).to eq 'ndlsh'
      expect(manifestation.subjects.first.term).to eq 'プログラミング (コンピュータ)'
      expect(manifestation.classifications.first.category).to eq '007.64'
      expect(manifestation.statement_of_responsibility).to eq '秋葉拓哉, 岩田陽一, 北川宜稔 著; Usu-ya 編'
      expect(manifestation.extent).to eq "315p"
      expect(manifestation.dimensions).to eq "24cm"
    end

    it "should import bibliographic record that does not have any classifications", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000003641700')
      expect(manifestation.original_title).to eq "アンパンマンとどうぶつえん"
      expect(manifestation.title_transcription).to eq "アンパンマン ト ドウブツエン"
    end

    it "should import volume_number_string", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000011037191')
      expect(manifestation.volume_number_string).to eq '上'
    end

    it "should import title_alternative", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000010926074')
      expect(manifestation.title_alternative).to eq 'PLATINADATA'
      expect(manifestation.title_alternative_transcription).to eq 'PLATINA DATA'
    end

    it "should import series_statement", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000004152429')
      expect(manifestation.original_title).to eq "ズッコケ三人組のダイエット講座"
      expect(manifestation.series_statements.first.original_title).to eq "ポプラ社文庫. ズッコケ文庫"
      expect(manifestation.serial).to be_falsy
    end

    it "should import series_statement's creator", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000008369884')
      expect(manifestation.series_statements.first.original_title).to eq "新・図書館学シリーズ"
      expect(manifestation.series_statements.first.creator_string).to eq "高山正也, 植松貞夫 監修"
    end

    it "should import series_statement transctiption", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000011242276')
      expect(manifestation.series_statements.first.original_title).to eq "講談社現代新書"
      expect(manifestation.series_statements.first.title_transcription).to eq "コウダンシャ ゲンダイ シンショ"
    end

    it "should import series_statement if the resource is serial", vcr: true, solr: true do
      manifestation = NdlBook.import_from_sru_response('R100000039-I3377584')
      expect(manifestation.original_title).to eq "週刊新潮"
      expect(manifestation.series_statements.first.original_title).to eq "週刊新潮"
      expect(manifestation.series_statements.first.series_master).to be_truthy
      expect(manifestation.serial).to be_truthy
      expect(manifestation.series_statements.first.root_manifestation).to eq manifestation
      expect(manifestation.root_series_statement).to eq manifestation.series_statements.first
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
      expect(manifestation.original_title).to eq "西日本哲学会会報"
      expect(manifestation.pub_date).to be_nil
    end

    it "should import url contain whitespace", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000002109818')
      expect(manifestation.original_title).to eq 'ザ・スコット・フィッツジェラルド・ブック'
      expect(manifestation.pub_date).to eq '1991'
    end

    it "should import audio cd", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000010273695')
      expect(manifestation.original_title).to eq "劇場版天元突破グレンラガン螺巌篇サウンドトラック・プラス"
      # 2024年の更新でSoundとして返ってくるようになった
      expect(manifestation.manifestation_content_type.name).to eq 'sounds'
    end

    it "should import video dvd", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000009149656')
      expect(manifestation.original_title).to eq "天元突破グレンラガン"
      expect(manifestation.manifestation_content_type.name).to eq 'two_dimensional_moving_image'
    end

    it "should not get volume number if book has not volume", vcr: true do
      expect(NdlBook.search('978-4-04-874013-5')[:items].first.title).to eq "天地明察"
    end

    it "should get volume number", vcr: true do
      expect(NdlBook.search('978-4-04-100292-6')[:items].first.volume).to eq "下"
    end

    it "should not get volume number if book has not volume", vcr: true do
      expect(NdlBook.search('978-4-04-874013-5')[:items].first.volume).to eq ""
    end

    it "should get series title", vcr: true do
      book = NdlBook.search("4840114404")[:items].first
      expect(book.series_title).to eq "マジック・ツリーハウス ; 15"
    end

    it "should not get series title if book has not series title", vcr: true do
      book = NdlBook.search("4788509105")[:items].first
      expect(book.series_title).to eq ""
    end

    it "should import publication_place", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000007725666')
      expect(manifestation.publication_place).to eq "つくば"
    end

    it "should import tactile_text", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000002368034')
      # 2024年の更新でBookとして返ってくるようになった
      # manifestation.manifestation_content_type.name.should eq 'tactile_text'
      expect(manifestation.manifestation_content_type.name).to eq 'text'
    end
    # it "should import computer_program", :vcr => true do
    #  manifestation = NdlBook.import_from_sru_response('R100000002-I000003048761')
    #  manifestation.manifestation_content_type.name.should eq 'computer_program'
    # end
    it "should import map", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I025478296')
      expect(manifestation.manifestation_content_type.name).to eq 'cartographic_image'
    end
    it "should import notated_music", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I025516419')
      expect(manifestation.manifestation_content_type.name).to eq 'notated_music'
    end
    it "should import photograph", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000010677225')
      expect(manifestation.manifestation_content_type.name).to eq 'still_image'
    end
    it "should import painting", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I000009199930')
      expect(manifestation.manifestation_content_type.name).to eq 'still_image'
    end
    it "should import picture postcard", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I024847245')
      expect(manifestation.manifestation_content_type.name).to eq 'still_image'
    end
    it "should import still_image", vcr: true do
      manifestation = NdlBook.import_from_sru_response('R100000002-I024016497')
      expect(manifestation.manifestation_content_type.name).to eq 'still_image'
    end

    it "should import ndc8 classification", vcr: true do
      manifestation = NdlBook.import_from_sru_response("R100000002-I000002467093")
      expect(manifestation.classifications).not_to be_empty
      expect(manifestation.classifications.first.classification_type.name).to eq "ndc8"
      expect(manifestation.classifications.first.category).to eq "547.48"
    end

    it "should import edition", vcr: true do
      manifestation = NdlBook.import_from_sru_response("R100000002-I025107686")
      expect(manifestation.edition_string).to eq "改訂第2版"
    end

    it "should import volume title", vcr: true do
      manifestation = NdlBook.import_from_sru_response("R100000002-I000011225479")
      expect(manifestation.original_title).to eq "じゃらん 関東・東北"
      expect(manifestation.title_transcription).to eq "ジャラン カントウ トウホク"
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
      expect(ndl_book.subjects[0]).to eq({ id: 'http://id.ndl.go.jp/auth/ndlsh/01058852', value: 'ウェブアプリケーション' })
      expect(ndl_book.subjects[1]).to eq({ id: 'http://id.ndl.go.jp/auth/ndlsh/00569223', value: 'プログラミング (コンピュータ)' })
    end

    it 'should get author IDs from NDLA', vcr: true do
      itemno = "R100000002-I028087126"
      url = "https://ndlsearch.ndl.go.jp/api/sru?operation=searchRetrieve&recordSchema=dcndl&maximumRecords=1&query=%28itemno=#{itemno}%29&onlyBib=true"
      xml = Faraday.get(url).body
      doc = Nokogiri::XML(Nokogiri::XML(xml).at('//xmlns:recordData').content)

      ndl_book = NdlBook.new(doc)
      expect(ndl_book.authors[0]).to eq({ id: "http://id.ndl.go.jp/auth/entity/00730574", name: "山田, 祥寛", transcription: "ヤマダ, ヨシヒロ" })
    end

    it "should respond to issued", vcr: true do
      books = NdlBook.search("Ruby")
      expect(books[:items][0].issued).to eq "2022.2"
    end
  end
end
