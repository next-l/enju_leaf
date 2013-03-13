# encoding: utf-8
require 'spec_helper'

describe ApplicationHelper do
  describe '#link_to_advanced_searchは' do
    let(:params) { {} }

    before do
      helper.stub(:params).and_return(params)
    end

    it '詳細検索画面へのリンクを生成すること' do
      html = helper.link_to_advanced_search
      html.should include(%Q[<a href="#{page_advanced_search_path}">])
      html.should include(">#{I18n.t('page.advanced_search')}</a>")
    end

    it '詳細検索画面へのリンクを、指定したリンクタイトルで生成すること' do
      html = helper.link_to_advanced_search('foobar')
      html.should include(%Q[<a href="#{page_advanced_search_path}">])
      html.should include('>foobar</a>')
    end

    it '詳細検索のためのパラメータを引き継いだリンクを生成すること' do
      ApplicationHelper::ADVANCED_SEARCH_PARAMS.each do |name|
        params[name] = name.to_s
      end
      params[:other] = 'other'

      html = helper.link_to_advanced_search

      m = html.match(/<a href="([^"]+)">/)
      m.should be_present

      path, qs = m[1].split(/\?/, 2)
      qs.should be_present

      qs.split(/&amp;/).each do |kv|
        k, v = kv.split(/=/, 2)
        params.include?(k.to_sym).should be_true, "unknown parameter: #{k.inspect}=#{v.inspect}"
        v.should eq(k)
      end
    end
  end

  describe '#link_to_normal_searchは' do
    let(:params) { {title: 'quux'} }

    before do
      helper.stub(:params).and_return(params)
    end

    it '通常検索画面へのリンクを生成すること' do
      html = helper.link_to_normal_search
      html.should include(%Q[<a href="#{manifestations_path}">])
      html.should include(">#{I18n.t('page.normal_search')}</a>")
    end

    it '通常検索画面へのリンクを、指定したリンクタイトルで生成すること' do
      html = helper.link_to_normal_search('foobar')
      html.should include(%Q[<a href="#{manifestations_path}">])
      html.should include('>foobar</a>')
    end

    it '詳細検索のためのパラメータ以外を引き継いだリンクを生成すること' do
      ApplicationHelper::ADVANCED_SEARCH_PARAMS.each do |name|
        params[name] = name.to_s
      end
      params[:other] = 'other'

      html = helper.link_to_normal_search

      m = html.match(/<a href="([^"]+)">/)
      m.should be_present

      path, qs = m[1].split(/\?/, 2)
      qs.should be_present
      html.should match(/<a href="([^"]+)">/)

      qs.split(/&amp;/).each do |kv|
        k, v = kv.split(/=/, 2)
        ApplicationHelper::ADVANCED_SEARCH_PARAMS.include?(k.to_sym).should be_false
        v.should eq(k)
      end
    end

    it '詳細検索のためのパラメータがなければリンクを生成しないこと' do
      params.clear

      helper.link_to_normal_search.should be_blank
    end
  end

  describe '#hidden_advanced_search_field_tagsは' do
    let(:params) { {} }

    before do
      helper.stub(:params).and_return(params)
    end

    it '詳細検索のためのパラメータ以外を引き継いぐhiddenタグを生成すること' do
      ApplicationHelper::ADVANCED_SEARCH_PARAMS.each do |name|
        params[name] = name.to_s
      end
      params[:other] = 'other'

      html = helper.hidden_advanced_search_field_tags

      cnt = 0
      html.scan(/<input([^<>]+)>/) do
        attrs = $1
        next unless /\btype=['"]hidden['"]/ =~ attrs

        cnt += 1
        name = attrs.match(/\bname=['"]([^'"]+)['"]/).try(:[], 1)
        value = attrs.match(/\bvalue=['"]([^'"]+)['"]/).try(:[], 1)
        ApplicationHelper::ADVANCED_SEARCH_PARAMS.include?(name.to_sym).should be_true
        value.should eq(name)
      end
      cnt.should eq(ApplicationHelper::ADVANCED_SEARCH_PARAMS.count)
    end
  end

  describe '#advanced_search_condition_summaryは' do
    let(:params) do
      ApplicationHelper::ADVANCED_SEARCH_PARAMS.inject({}) do |hsh, name|
        hsh[name] = name.to_s
        hsh
      end
    end

    before do
      helper.stub(:params).and_return(params)
    end

    it '指定内容を表示すること' do
      params[:query] = 'query'
      params[:tag] = ''
      params[:title_merge] = 'exact'
      params.delete(:creator_merge)
      params.delete(:except_publisher)

      html = helper.advanced_search_condition_summary

      html.should match(/\A\(.+\)\z/)
      html.should_not include('tag')
      [
        [t('page.title'), "title[#{t('page.exact_title')}]"],
        [t('patron.creator'), "creator"],
        [t('patron.publisher'), 'publisher'],
        [t('activerecord.attributes.manifestation.isbn'), 'isbn'],
        [t('activerecord.attributes.manifestation.issn'), 'issn'],
        [t('activerecord.attributes.item.item_identifier'), 'item_identifier'],
        [t('activerecord.attributes.manifestation.date_of_publication'), 'pub_date_from-pub_date_to'],
        [t('activerecord.attributes.item.acquired_at'), 'acquired_from-acquired_to'],
        [t('activerecord.attributes.item.removed_at'), 'removed_from-removed_to'],
        [t('page.number_of_pages'), 'number_of_pages_at_least-number_of_pages_at_most'],
        ["#{t('page.except_search_term')}#{t('page.search_term')}", "except_query"],
        ["#{t('page.except_title')}#{t('page.title')}", "except_title"],
        ["#{t('page.except_creator')}#{t('patron.creator')}", "except_creator"],
      ].each do |label, value|
        html.should include("#{label}: #{value}")
      end
    end

    it '範囲項目の始端が指定されないとき、片側のみ表示すること' do
      params.delete(:pub_date_from)
      params.delete(:acquired_from)
      params.delete(:removed_from)
      params.delete(:number_of_pages_at_least)

      html = helper.advanced_search_condition_summary

      [
        ['activerecord.attributes.manifestation.date_of_publication', '-pub_date_to'],
        ['activerecord.attributes.item.acquired_at', '-acquired_to'],
        ['activerecord.attributes.item.removed_at', '-removed_to'],
        ['page.number_of_pages', '-number_of_pages_at_most'],
      ].each do |label_id, value|
        html.should include("#{t(label_id)}: #{value}")
      end
    end

    it '範囲項目の終端が指定されないとき、片側のみ表示すること' do
      params.delete(:pub_date_to)
      params.delete(:acquired_to)
      params.delete(:removed_to)
      params.delete(:number_of_pages_at_most)

      html = helper.advanced_search_condition_summary

      [
        ['activerecord.attributes.manifestation.date_of_publication', 'pub_date_from-'],
        ['activerecord.attributes.item.acquired_at', 'acquired_from-'],
        ['activerecord.attributes.item.removed_at', 'removed_from-'],
        ['page.number_of_pages', 'number_of_pages_at_least-'],
      ].each do |label_id, value|
        html.should include("#{t(label_id)}: #{value}")
      end
    end

    it '詳細検索のためのパラメータがなければ空文字列を返すこと' do
      params.clear
      helper.advanced_search_condition_summary.should be_blank
    end

    it '表示項目数が指定されていたら、その数だけ表示すること' do
      html = helper.advanced_search_condition_summary(:length => 3)
      html.scan(/#{Regexp.quote(t('page.advanced_search_summary_delimiter'))}/).should have(2).items
    end

    it '表示項目数と省略文字が指定されていたら、省略があったときにそれを表示すること' do
      keys = params.keys[0, 4]
      params.delete_if {|k, v| !keys.include?(k) }
      params[:query] = 'query'

      html = helper.advanced_search_condition_summary(:length => 3, :omission => '、他')
      html.should match(/、他\)\z/)

      html = helper.advanced_search_condition_summary(:length => 4, :omission => '、他')
      html.should_not match(/、他/)

      html = helper.advanced_search_condition_summary(:omission => '、他')
      html.should_not match(/、他/)
    end

    it 'solr_commitが指定されていたら何も表示しないこと' do
      params[:solr_commit] = true
      helper.advanced_search_condition_summary.should be_blank
    end
  end

  describe '#advanced_search_merge_tagは' do
    let(:params) { {} }

    before do
      helper.stub(:params).and_return(params)
    end

    [
      ['title', %w(exact all any)],
      ['creator', %w(exact all any)],
      ['publisher', %w(exact all any)],
      ['query', %w(all any)],
    ].each do |name, values|
      values.each do |pvalue|
        pname = "#{name}_merge"
        it "#{pname}パラメータが#{pvalue}のときname=#{pname} value=#{pvalue}のボタンをチェックした状態で表示すること" do
          params[pname.to_sym] = pvalue

          html = helper.advanced_search_merge_tag(name)

          found = false
          html.scan(/<input(.+?)>/) do
            n = t = v = c = nil
            $1.scan(/(\S+)="(.+?)"/) do
              case $1.downcase
              when 'name'; n = $2
              when 'type'; t = $2
              when 'value'; v = $2
              when 'checked'; c = true
              end
            end
            next unless n == pname
            found = true

            if v == pvalue
              c.should be_true, "expected <input type=\"#{t}\" name=\"#{n}\" value=\"#{v}\" checked>, but not checked"
            else
              c.should be_false, "expected <input type=\"#{t}\" name=\"#{n}\" value=\"#{v}\">, but checked"
            end
          end
          found.should be_true, "expected <input name=\"#{pname}\" value=\"#{pvalue}\" checked>, but not found"
        end
      end
    end
  end
end
