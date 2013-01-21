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
end
