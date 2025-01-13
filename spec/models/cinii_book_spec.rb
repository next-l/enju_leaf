require 'rails_helper'

describe CiniiBook do
  fixtures :all

  it "should search bibliographic records", vcr: true do
    CiniiBook.search("library system")[:total_entries].should eq 3934
  end

  it "should search with ncid", vcr: true do
    result = CiniiBook.search("BA85746967")
    result.should be_truthy
    result[:items].should be_truthy
    result[:items].first.ncid.should eq "BA85746967"
  end

  it "should import a bibliographic record", vcr: true do
    book = CiniiBook.import_ncid("BA85746967")
    book.should be_truthy
    book.should be_valid
    book.original_title.should eq "固体高分子形燃料電池要素材料・水素貯蔵材料の知的設計 = Intelligent/directed materials design for polymer electrolyte fuel cells and hydrogen storage applications"
    book.title_transcription.should include("コタイ コウブンシケイ ネンリョウ デンチ ヨウソ ザイリョウ スイソ チョゾウ ザイリョウ ノ チテキ セッケイ")
    book.title_alternative.should include("固体高分子形燃料電池要素材料水素貯蔵材料の知的設計")
    book.title_alternative.should include("Computational materials design, case study I")
    book.statement_of_responsibility.should eq "笠井秀明, 津田宗幸著 = Hideaki Kasai, Muneyuki Tsuda"
    book.publishers.first.full_name.should eq "大阪大学出版会"
    book.language.iso_639_2.should eq "jpn"
    book.date_of_publication.year.should eq 2008
    book.extent.should eq "iv, 144p"
    book.dimensions.should eq "21cm"
    expect(book.ncid_record.body).to eq "BA85746967"
    expect(book.isbn_records.first.body).to eq "9784872592542"
    book.creators.size.should eq 2
    book.creators[0].full_name.should eq "笠井, 秀明"
    book.creators[1].full_name.should eq "津田, 宗幸"
    book.subjects.map{|e| e.term }.should include("工業材料")
    book.subjects.map{|e| e.term }.should include("燃料電池")
    book.subjects.map{|e| e.term }.should include("水素エネルギー")
    book.subjects.map{|e| e.term }.should include("シミュレーション")
    book.series_statements.size.should eq 2
    book.series_statements[0].series_statement_identifier.should eq "https://ci.nii.ac.jp/ncid/BA61636068"
    book.series_statements[0].original_title.should eq "大阪大学新世紀レクチャー"
    book.series_statements[0].title_transcription.should eq "オオサカ ダイガク シンセイキ レクチャー"
    book.series_statements[1].original_title.should eq "計算機マテリアルデザイン先端研究事例"
    book.series_statements[1].title_transcription.should eq "ケイサンキ マテリアル デザイン センタン ケンキュウ ジレイ"
  end

  it "should import a bibliographic record with dual languages", vcr: true do
    book = CiniiBook.import_ncid("BB13942810")
    book.should be_truthy
    book.should be_valid
    book.original_title.should eq "赤毛のアン = Anne of Green Gables"
    book.language.iso_639_2.should eq "jpn"
  end
end
