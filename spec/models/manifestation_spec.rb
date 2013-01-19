# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Manifestation, :solr => true do
  fixtures :all
  use_vcr_cassette "enju_ndl/manifestation", :record => :new_episodes

  it "should set pub_date" do
    manifestation = FactoryGirl.create(:manifestation, :pub_date => '2000')
    manifestation.date_of_publication.should eq Time.zone.parse('2000-12-31').end_of_month
  end

  it "should set number from serial_number_string" do
    manifestation = FactoryGirl.create(:manifestation, :serial_number_string => '通号29号')
    manifestation.serial_number.should eq 29
  end

  it "should set volume from volume_number_string" do
    manifestation = FactoryGirl.create(:manifestation, :volume_number_string => '第29巻')
    manifestation.volume_number.should eq 29
  end

  it "should clear volume_number (over limit length)" do
    manifestation = FactoryGirl.create(:manifestation, :volume_number_string => '第29/30巻(第2部門 講義 1919-44)')
    manifestation.volume_number.should be_nil
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
    # 全角半角が判定できていないため以下の文はエラー判定になる
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
    manifestations(:manifestation_00007).is_reserved_by(users(:admin)).should be_true
  end

  it "should not be reserved" do
    manifestations(:manifestation_00007).is_reserved_by(users(:user1)).should be_nil
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
    #TODO: system_configatronの設定によって条件変化
    #manifestations(:manifestation_00008).reservable?.should be_false
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

  describe '.searchは' do
    subject { Manifestation }

    let(:exact_word) { 'アジャイル' }
    let(:typo_word)  { 'アジイャル' }
    let(:exact_title) { "Railsによる#{exact_word}Webアプリケーション開発" }
    let(:typo_title)  { "Railsによる#{typo_word }Webアプリケーション開発" }

    let(:search_spec) do
      proc {
        fulltext exact_title
      }
    end

    before do
      Sunspot.remove_all!

      @manifestation_type = FactoryGirl.create(:manifestation_type)
      @manifestation = FactoryGirl.create(
        :manifestation,
        :original_title => exact_title,
        :manifestation_type => @manifestation_type)

      Sunspot.commit
    end

    def do_test_search
      @result = subject.search(&search_spec).execute
    end

    it '書名により検索できること' do
      do_test_search

      @result.results.should have(1).item
      @result.results.first.should == @manifestation

      @result.raw_suggestions.should be_nil
      @result.suggestions.should be_nil
      @result.collation.should be_nil
    end

    shared_examples_for '「もしかして」検索' do
      it '「もしかして」検索ができること' do
        do_test_search

        @result.results.should have(:no).items

        raw = @result.raw_suggestions
        raw.should be_a(Array)
        raw.each_slice(2).to_a.assoc(typo_word).should be_present

        sug = @result.suggestions
        sug.should be_a(Hash)
        sug.should be_include(typo_word)
        sug[typo_word].should == [exact_word]
      end
    end

    context 'spellcheck指定があるとき' do
      let(:search_spec) do
        proc {
          fulltext typo_title
          spellcheck
        }
      end
      include_examples '「もしかして」検索'

      it 'collationを返さないこと' do
        do_test_search
        @result.collation.should be_nil
      end
    end

    context 'spellcheck collate指定があるとき' do
      let(:search_spec) do
        proc {
          fulltext typo_title
          spellcheck collate: true
        }
      end
      include_examples '「もしかして」検索'

      it 'collationを返すこと' do
        do_test_search
        @result.collation.should be_present
        @result.collation.first.should == exact_title
      end
    end

    context 'spellcheck collate=>3指定があるとき' do
      before do
        [
          'JRuby on Rails実践開発ガイド',
          '実践Ruby on Rails Webプログラミング入門 : 無駄なく迅速な開発環境 : Webアプリケーション開発を加速するJavaエンジニアのためのRoR入門!',
          'はじめてのGrails : 「Ruby on Rails」風の「フレームワーク」をJavaで使いこなす!',
        ].each do |title|
          FactoryGirl.create(
            :manifestation,
            :original_title => title,
            :manifestation_type => @manifestation_type)
        end
        Sunspot.commit
      end

      let(:search_spec) do
        proc {
          fulltext 'ruy on rails'
          spellcheck collate: 3
        }
      end

      it 'collationを複数返すこと' do
        do_test_search
        @result.collation.should be_present
        @result.collation.count.should > 1
      end
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
#  identifier                      :string(255)
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
#  volume_number_list              :string(255)
#  issue_number_list               :string(255)
#  serial_number_list              :string(255)
#  edition                         :integer
#  note                            :text
#  produces_count                  :integer         default(0), not null
#  exemplifies_count               :integer         default(0), not null
#  embodies_count                  :integer         default(0), not null
#  work_has_subjects_count         :integer         default(0), not null
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
#  nii_type_id                     :integer
#  title_alternative_transcription :text
#  description                     :text
#  abstract                        :text
#  available_at                    :datetime
#  valid_until                     :datetime
#  date_submitted                  :datetime
#  date_accepted                   :datetime
#  date_caputured                  :datetime
#  file_hash                       :string(255)
#  pub_date                        :string(255)
#  periodical_master               :boolean         default(FALSE), not null
#

