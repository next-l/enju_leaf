# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Manifestation, :solr => true do
  fixtures :all
  use_vcr_cassette "enju_ndl/manifestation", :record => :new_episodes

  it "should set pub_date" do
    patron = FactoryGirl.create(:manifestation, :pub_date => '2000')
    patron.date_of_publication.should eq Time.zone.parse('2000-01-01')
  end

  it "should search title in openurl" do
    openurl = Openurl.new({:title => "プログラミング"})
    results = openurl.search
    openurl.query_text.should eq "btitle_text:プログラミング"
    results.size.should eq 8
    openurl = Openurl.new({:jtitle => "テスト"})
    results = openurl.search
    results.size.should eq 2
    openurl.query_text.should eq "jtitle_text:テスト"
    openurl = Openurl.new({:atitle => "2005"})
    results = openurl.search
    results.size.should eq 1
    openurl.query_text.should eq "atitle_text:2005"
    openurl = Openurl.new({:atitle => "テスト", :jtitle => "2月号"})
    results = openurl.search
    results.size.should eq 1
  end

  it "should search patron in openurl" do
    openurl = Openurl.new({:aulast => "Administrator"})
    results = openurl.search
    openurl.query_text.should eq "au_text:Administrator"
    results.size.should eq 2
    openurl = Openurl.new({:aufirst => "名称"})
    results = openurl.search
    openurl.query_text.should eq "au_text:名称"
    results.size.should eq 1
    openurl = Openurl.new({:au => "テスト"})
    results = openurl.search
    openurl.query_text.should eq "au_text:テスト"
    results.size.should eq 1
    openurl = Openurl.new({:pub => "Administrator"})
    results = openurl.search
    openurl.query_text.should eq "publisher_text:Administrator"
    results.size.should eq 4
  end

  it "should search isbn in openurl" do
    openurl = Openurl.new({:api => "openurl", :isbn => "4798"})
    results = openurl.search
    openurl.query_text.should eq "isbn_sm:4798*"
    results.size.should eq 2
  end

  it "should search issn in openurl" do
    openurl = Openurl.new({:api => "openurl", :issn => "1234"})
    results = openurl.search
    openurl.query_text.should eq "issn_s:1234*"
    results.size.should eq 2
  end

  it "should search any in openurl" do
    openurl = Openurl.new({:any => "テスト"})
    results = openurl.search
    results.size.should eq 9
  end

  it "should serach multi in openurl" do
    openurl = Openurl.new({:btitle => "CGI Perl プログラミング"})
    results = openurl.search
    results.size.should eq 3
    openurl = Openurl.new({:jtitle => "テスト", :pub => "テスト"})
    results = openurl.search
    results.size.should eq 2
  end

  it "shoulld get search_error in openurl" do
    lambda{Openurl.new({:isbn => "12345678901234"})}.should raise_error(OpenurlQuerySyntaxError)
    lambda{Openurl.new({:issn => "1234abcd"})}.should raise_error(OpenurlQuerySyntaxError)
    lambda{Openurl.new({:aufirst => "テスト 名称"})}.should raise_error(OpenurlQuerySyntaxError)
  end

  it "should search in sru" do
    sru = Sru.new({:query => "title=Ruby"})
    sru.search
    sru.manifestations.size.should eq 18
    sru.manifestations.first.titles.first.should eq 'Ruby'
    sru = Sru.new({:query => "title=^ruby"})
    sru.search
    sru.manifestations.size.should eq 9
    sru = Sru.new({:query => 'title ALL "awk sed"'})
    sru.search
    sru.manifestations.size.should eq 2
    sru.manifestations.collect{|m| m.id}.should eq [184, 116]
    sru = Sru.new({:query => 'title ANY "ruby awk sed"'})
    sru.search
    sru.manifestations.size.should eq 22
    sru = Sru.new({:query => 'isbn=9784756137470'})
    sru.search
    sru.manifestations.first.id.should eq 114
    sru = Sru.new({:query => "creator=テスト"})
    sru.search
    sru.manifestations.size.should eq 1
  end

  it "should search date in sru" do
    sru = Sru.new({:query => "from = 2000-09 AND until = 2000-11-01"})
    sru.search
    sru.manifestations.size.should eq 1
    sru.manifestations.first.id.should eq 120
    sru = Sru.new({:query => "from = 1993-02-24"})
    sru.search
    sru.manifestations.size.should eq 5
    sru = Sru.new({:query => "until = 2006-08-06"})
    sru.search
    sru.manifestations.size.should eq 4
  end

  it "should accept sort_by in sru" do
    sru = Sru.new({:query => "title=Ruby"})
    sru.sort_by.should eq({:sort_by => 'created_at', :order => 'desc'})
    sru = Sru.new({:query => 'title=Ruby AND sortBy="title/sort.ascending"', :sortKeys => 'creator,0', :version => '1.2'})
    sru.sort_by.should eq({:sort_by => 'sort_title', :order => 'asc'})
    sru = Sru.new({:query => 'title=Ruby AND sortBy="title/sort.ascending"', :sortKeys => 'creator,0', :version => '1.1'})
    sru.sort_by.should eq({:sort_by => 'creator', :order => 'desc'})
    sru = Sru.new({:query => 'title=Ruby AND sortBy="title/sort.ascending"', :sortKeys => 'creator,1', :version => '1.1'})
    sru.sort_by.should eq({:sort_by => 'creator', :order => 'asc'})
    sru = Sru.new({:query => 'title=Ruby AND sortBy="title'})
    sru.sort_by.should eq({:sort_by => 'sort_title', :order => 'asc'})
    #TODO ソート基準が入手しやすさの場合の処理
  end

  it "should accept rangs in sru" do
    sru = Sru.new({:query => "from = 1993-02-24 AND until = 2006-08-06 AND title=プログラミング"})
    sru.search
    sru.manifestations.size.should eq 2
    sru = Sru.new({:query => "until = 2000 AND title=プログラミング"})
    sru.search
    sru.manifestations.size.should eq 1
    sru = Sru.new({:query => "from = 2006 AND title=プログラミング"})
    sru.search
    sru.manifestations.size.should eq 1
    sru = Sru.new({:query => "from = 2007 OR title=awk"})
    sru.search
    sru.manifestations.size.should eq 6
  end

  it "should be reserved" do
    manifestations(:manifestation_00007).is_reserved_by?(users(:admin)).should be_true
  end

  it "should not be reserved" do
    manifestations(:manifestation_00007).is_reserved_by?(users(:user1)).should be_false
  end

  it "should_get_number_of_pages" do
    manifestations(:manifestation_00001).number_of_pages.should eq 100
  end

  it "should get youtube_id" do
    manifestations(:manifestation_00022).youtube_id.should eq 'BSHBzd9ftDE'
  end

  it "should get nicovideo_id" do
    manifestations(:manifestation_00023).nicovideo_id.should eq 'sm3015373'
  end

  it "should have parent_of_series" do
    manifestations(:manifestation_00001).parent_of_series.should be_true
  end

  it "should respond to extract_text" do
    manifestations(:manifestation_00001).extract_text.should be_nil
  end

  it "should not be reserved it it has no item" do
    manifestations(:manifestation_00008).is_reservable_by?(users(:admin)).should be_false
  end

  it "should respond to title" do
    manifestations(:manifestation_00001).title.should be_true
  end

  it "should import isbn" do
    Manifestation.import_isbn('4797327030').should be_valid
  end

  it "should respond to pickup" do
    Manifestation.pickup.should_not raise_error(ActiveRecord::RecordNotFound)
  end

  if defined?(EnjuCirculation)
    it "should respond to is_checked_out_by?" do
      manifestations(:manifestation_00001).is_checked_out_by?(users(:admin)).should be_true
      manifestations(:manifestation_00001).is_checked_out_by?(users(:librarian2)).should be_false
    end
  end
end

# == Schema Information
#
# Table name: manifestations
#
#  id                              :integer         not null, primary key
#  original_title                  :text            not null
#  title_alternative               :text
#  title_transcription             :text
#  classification_number           :string(255)
#  manifestation_identifier        :string(255)
#  date_of_publication             :datetime
#  date_copyrighted                :datetime
#  created_at                      :datetime
#  updated_at                      :datetime
#  deleted_at                      :datetime
#  access_address                  :string(255)
#  language_id                     :integer         default(1), not null
#  carrier_type_id                 :integer         default(1), not null
#  extent_id                       :integer         default(1), not null
#  start_page                      :integer
#  end_page                        :integer
#  height                          :decimal(, )
#  width                           :decimal(, )
#  depth                           :decimal(, )
#  isbn                            :string(255)
#  isbn10                          :string(255)
#  wrong_isbn                      :string(255)
#  nbn                             :string(255)
#  lccn                            :string(255)
#  oclc_number                     :string(255)
#  issn                            :string(255)
#  price                           :integer
#  fulltext                        :text
#  volume_number_string            :string(255)
#  issue_number_string             :string(255)
#  serial_number_string            :string(255)
#  edition                         :integer
#  note                            :text
#  repository_content              :boolean         default(FALSE), not null
#  lock_version                    :integer         default(0), not null
#  required_role_id                :integer         default(1), not null
#  state                           :string(255)
#  required_score                  :integer         default(0), not null
#  frequency_id                    :integer         default(1), not null
#  subscription_master             :boolean         default(FALSE), not null
#  ipaper_id                       :integer
#  ipaper_access_key               :string(255)
#  attachment_file_name            :string(255)
#  attachment_content_type         :string(255)
#  attachment_file_size            :integer
#  attachment_updated_at           :datetime
#  title_alternative_transcription :text
#  description                     :text
#  abstract                        :text
#  available_at                    :datetime
#  valid_until                     :datetime
#  date_submitted                  :datetime
#  date_accepted                   :datetime
#  date_caputured                  :datetime
#  ndl_bib_id                      :string(255)
#  file_hash                       :string(255)
#  pub_date                        :string(255)
#  edition_string                  :string(255)
#  volume_number                   :integer
#  issue_number                    :integer
#  serial_number                   :integer
#  ndc                             :string(255)
#

