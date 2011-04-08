# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Manifestation do
  fixtures :all

  it "should set pub_date" do
    patron = Factory(:manifestation, :pub_date => '2000')
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
    openurl.query_text.should eq "isbn_text:4798*"
    results.size.should eq 2
  end

  it "should search issn in openurl" do
    openurl = Openurl.new({:api => "openurl", :issn => "1234"})
    results = openurl.search
    openurl.query_text.should eq "issn_text:1234*"
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

  it "should accept sort_by in sru" do
    sru = Sru.new({:query => "title=Ruby"})
    sru.sort_by.should eq ({:sort_by => 'created_at', :order => 'desc'})
    sru = Sru.new({:query => 'title=Ruby AND sortBy="title/sort.ascending"', :sortKeys => 'creator,0', :version => '1.2'})
    sru.sort_by.should eq ({:sort_by => 'sort_title', :order => 'asc'})
    sru = Sru.new({:query => 'title=Ruby AND sortBy="title/sort.ascending"', :sortKeys => 'creator,0', :version => '1.1'})
    sru.sort_by.should eq ({:sort_by => 'creator', :order => 'desc'})
    sru = Sru.new({:query => 'title=Ruby AND sortBy="title/sort.ascending"', :sortKeys => 'creator,1', :version => '1.1'})
    sru.sort_by.should eq ({:sort_by => 'creator', :order => 'asc'})
    sru = Sru.new({:query => 'title=Ruby AND sortBy="title'})
    sru.sort_by.should eq ({:sort_by => 'sort_title', :order => 'asc'})
    #TODO ソート基準が入手しやすさの場合の処理
  end
end
