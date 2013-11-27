# encoding: utf-8
require 'spec_helper'

describe "manifestations/index" do
  before do
    assign(:index_patron, {})
    assign(:manifestation, nil)
    assign(:series_statement, nil)
    assign(:binder, nil)
  end

  context '検索結果が0のとき' do
    before do
      manifestations = []
      manifestations.stub(:total_count => 0)
      assign(:manifestations, manifestations)
      assign(:count, {:query_result => 0})
    end

    it 'not_foundをレンダリングすること' do
      render
      response.should render_template('manifestations/_not_found')
    end

    context 'Solrからのcollationがあれば' do
      before do
        @collation = assign(:collation, %w(foo bar baz))
      end

      it '「もしかして」を表示すること' do
        render

        assert_select "p", :text => /#{Regexp.quote(I18n.t('page.did_you_mean_to_search_for'))}/ do
          assert_select "a[href=?]", manifestations_path(:query => 'foo')
          assert_select "a[href=?]", manifestations_path(:query => 'bar')
          assert_select "a[href=?]", manifestations_path(:query => 'baz')
        end
      end
    end
  end

  context 'インデックスがnacsisのとき' do
    include NacsisCatSpecHelper

    let(:book_record) do
      NacsisCat.new(record: nacsis_record_object(:book))
    end

    let(:serial_record) do
      NacsisCat.new(record: nacsis_record_object(:serial))
    end

    before do
      params[:index] = 'nacsis'
    end

    context 'nacsis.search_eachがtrueなら' do

      before do
        update_system_configuration('nacsis.search_each', true)
        assign(:manifestations_book,
                Kaminari.paginate_array([book_record]).page(1))
        assign(:manifestations_serial,
                Kaminari.paginate_array([serial_record]).page(1))
        assign(:count, {
          query_result_book: 1,
          query_result_serial: 1,
        })
      end

      it '検索結果を分割表示すること' do
        render
        assert_select 'table.index', count: 2 do
          assert_select "tr td", count: 2
        end
      end

      it 'レコードへのリンクを表示すること' do
        render
        assert_select "a[href=?]",
          nacsis_manifestations_path(ncid: book_record.ncid, manifestation_type: 'book')
        assert_select "a[href=?]",
          nacsis_manifestations_path(ncid: serial_record.ncid, manifestation_type: 'serial')
      end
    end

    context 'nacsis.search_eachがfalseなら' do
      before do
        update_system_configuration('nacsis.search_each', false)
        assign(:manifestations,
                Kaminari.paginate_array([book_record, serial_record]).page(1))
        assign(:count, {
          query_result: 2,
        })
      end

      it '検索結果を表示すること' do
        render
        assert_select 'table.index', count: 1 do
          assert_select "tr td", count: 2
        end
      end

      it 'レコードへのリンクを表示すること' do
        render
        assert_select "a[href=?]",
          nacsis_manifestations_path(ncid: book_record.ncid, manifestation_type: 'book')
        assert_select "a[href=?]",
          nacsis_manifestations_path(ncid: serial_record.ncid, manifestation_type: 'serial')
      end
    end
  end
end
