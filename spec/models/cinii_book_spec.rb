require 'rails_helper'

describe CiniiBook do
  fixtures :all

  it "should search bibliographic records", vcr: true do
    expect(CiniiBook.search("library system")[:total_entries]).to eq 3934
  end

  it "should search with ncid", vcr: true do
    result = CiniiBook.search("BA85746967")
    expect(result).to be_truthy
    expect(result[:items]).to be_truthy
    expect(result[:items].first.ncid).to eq "BA85746967"
  end

  it "should import a bibliographic record", vcr: true do
    book = CiniiBook.import_ncid("BA85746967")
    expect(book).to be_truthy
    expect(book).to be_valid
    expect(book.original_title).to eq "固体高分子形燃料電池要素材料・水素貯蔵材料の知的設計 = Intelligent/directed materials design for polymer electrolyte fuel cells and hydrogen storage applications"
    expect(book.title_transcription).to include("コタイ コウブンシケイ ネンリョウ デンチ ヨウソ ザイリョウ スイソ チョゾウ ザイリョウ ノ チテキ セッケイ")
    expect(book.title_alternative).to include("固体高分子形燃料電池要素材料水素貯蔵材料の知的設計")
    expect(book.title_alternative).to include("Computational materials design, case study I")
    expect(book.statement_of_responsibility).to eq "笠井秀明, 津田宗幸著 = Hideaki Kasai, Muneyuki Tsuda"
    expect(book.publishers.first.full_name).to eq "大阪大学出版会"
    expect(book.language.iso_639_2).to eq "jpn"
    expect(book.date_of_publication.year).to eq 2008
    expect(book.extent).to eq "iv, 144p"
    expect(book.dimensions).to eq "21cm"
    expect(book.ncid_record.body).to eq "BA85746967"
    expect(book.isbn_records.first.body).to eq "9784872592542"
    expect(book.creators.size).to eq 2
    expect(book.creators[0].full_name).to eq "笠井, 秀明"
    expect(book.creators[1].full_name).to eq "津田, 宗幸"
    expect(book.subjects.map { |e| e.term }).to include("工業材料")
    expect(book.subjects.map { |e| e.term }).to include("燃料電池")
    expect(book.subjects.map { |e| e.term }).to include("水素エネルギー")
    expect(book.subjects.map { |e| e.term }).to include("シミュレーション")
    expect(book.series_statements.size).to eq 2
    expect(book.series_statements[0].series_statement_identifier).to eq "https://ci.nii.ac.jp/ncid/BA61636068"
    expect(book.series_statements[0].original_title).to eq "大阪大学新世紀レクチャー"
    expect(book.series_statements[0].title_transcription).to eq "オオサカ ダイガク シンセイキ レクチャー"
    expect(book.series_statements[1].original_title).to eq "計算機マテリアルデザイン先端研究事例"
    expect(book.series_statements[1].title_transcription).to eq "ケイサンキ マテリアル デザイン センタン ケンキュウ ジレイ"
  end

  it "should import a bibliographic record with dual languages", vcr: true do
    book = CiniiBook.import_ncid("BB13942810")
    expect(book).to be_truthy
    expect(book).to be_valid
    expect(book.original_title).to eq "赤毛のアン = Anne of Green Gables"
    expect(book.language.iso_639_2).to eq "jpn"
  end
end
