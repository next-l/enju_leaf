# encoding: utf-8
require 'spec_helper'

describe ManifestationsController do
  fixtures :all

  describe '#indexは', :solr => true do
    let(:user) { FactoryGirl.create(:user) }
    let(:admin) { FactoryGirl.create(:admin) }
    let(:librarian) { FactoryGirl.create(:librarian) }

    it 'ログインしているとき@reserve_userにログインしているユーザを設定すること' do
      sign_in user

      get :index
      response.should be_success
      assigns(:reserve_user).should eq(user)
    end

    it 'ログインしていないとき@reserve_userにnilを設定すること' do
      get :index
      response.should be_success
      assigns(:reserve_user).should be_nil
    end

    describe 'user_idパラメータが指定されたとき' do
      let(:param_user) { FactoryGirl.create(:user) }

      it '管理者であれば@reserve_userに対応するユーザを設定すること' do
        sign_in admin

        get :index, user_id: param_user.id.to_s
        response.should be_success
        assigns(:reserve_user).should eq(param_user)
      end

      it '図書館員であれば@reserve_userに対応するユーザを設定すること' do
        sign_in librarian

        get :index, user_id: param_user.id.to_s
        response.should be_success
        assigns(:reserve_user).should eq(param_user)
      end

      it '一般ユーザであれば@reserve_userにログイン中のユーザ(自身)を設定すること' do
        sign_in user

        get :index, user_id: param_user.id.to_s
        response.should be_success
        assigns(:reserve_user).should eq(user)
      end

      it 'ログインしていなければ@reserve_userにnilを設定すること' do
        get :index, user_id: param_user.id.to_s
        response.should be_success
        assigns(:reserve_user).should be_nil
      end

      it 'それが存在しないユーザなら@reserve_userにログイン中のユーザ(自身)を設定すること' do
        sign_in admin

        max_id = User.order(:id).last.id
        get :index, user_id: (max_id + 100).to_s
        response.should be_success
        assigns(:reserve_user).should eq(admin)
      end
    end

    describe 'indexパラメータがnacsisのとき' do
      include NacsisCatSpecHelper

      let(:nacsis_cat) { nacsis_cat_with_mock_record(:book) }
      let(:ncid) { nacsis_cat.record.bibliog_id }

      def reverse_merge_default_page_options(opts)
        opts.reverse_merge({:page => 1, :per_page => 10})
      end

      def nacsis_cat_should_receive_search_with(opts, return_value = nil)
        return_value ||= NacsisCat::ResultArray.new(nil)
        opts = reverse_merge_default_page_options(opts) if opts.is_a?(Hash)
        NacsisCat.should_receive(:search).
          with(opts).and_return(return_value)
      end

      it 'NACSIS-CAT検索を実行すること' do
        nacsis_cat_should_receive_search_with(any_args) # book
        nacsis_cat_should_receive_search_with(any_args) # serial
        get :index, :index => 'nacsis', :ncid => ncid
        response.should be_success
      end

      it '検索条件が空のとき@manifestationsを空にすること' do
        EnjuNacsisCatp::CatGatewayClient.any_instance.
          should_not_receive(:execute)

        get :index, :index => 'nacsis'
        response.should be_success
        assigns(:manifestations).should eq(NacsisCat::ResultArray.new(nil))
      end

      it '書誌の種類の指定がなければ一般および雑誌の書誌を検索対象とすること' do
        nacsis_cat_should_receive_search_with(:db => :book, :id => 'foo')
        nacsis_cat_should_receive_search_with(:db => :serial, :id => 'foo')
        get :index, :index => 'nacsis', :ncid => 'foo'
      end

      it '書誌の種類の指定がbookとserialのとき、一般および雑誌の書誌を検索対象とすること' do
        nacsis_cat_should_receive_search_with(:db => :book, :id => 'foo')
        nacsis_cat_should_receive_search_with(:db => :serial, :id => 'foo')
        get :index, :index => 'nacsis', :ncid => 'foo', :manifestation_type => %w(book serial)
      end

      it '書誌の種類の指定がbookのとき、一般書誌を検索対象とすること' do
        nacsis_cat_should_receive_search_with(:db => :book, :id => 'foo')
        get :index, :index => 'nacsis', :ncid => 'foo', :manifestation_type => %w(book)
      end

      it '書誌の種類の指定がserialのとき、雑誌書誌を検索対象とすること' do
        nacsis_cat_should_receive_search_with(:db => :serial, :id => 'foo')
        get :index, :index => 'nacsis', :ncid => 'foo', :manifestation_type => %w(serial)
      end

      it '検索条件が否定形のみのとき@manifestationsを空にすること' do
        EnjuNacsisCatp::CatGatewayClient.any_instance.
          should_not_receive(:execute)

        get :index, :index => 'nacsis', :except_title => 'foo'
        response.should be_success
        assigns(:manifestations).should eq(NacsisCat::ResultArray.new(nil))
      end

      [:isbn, :issn, :ncid].each do |name|
        if name == :ncid
          sname = :id
        else
          sname = name
        end

        describe "#{name}パラメータが指定されたとき" do
          it "#{sname.inspect}でNacsisCat.searchを実行すること" do
            nacsis_cat_should_receive_search_with(sname => 'foo bar', :db => :book)
            nacsis_cat_should_receive_search_with(sname => 'foo bar', :db => :serial)
            get :index, :index => 'nacsis',
              name => 'foo bar'
            response.should be_success
          end
        end
      end

      [:query, :title, :creator, :publisher, :subject].each do |name|
        if name == :creator
          sname = :author
        else
          sname = name
        end

        describe "#{name}パラメータが指定されたとき" do
          it "#{name.inspect}でNacsisCat.searchを実行すること" do
            nacsis_cat_should_receive_search_with(sname => ['foo', 'bar'], :db => :book)
            nacsis_cat_should_receive_search_with(sname => ['foo', 'bar'], :db => :serial)
            get :index, :index => 'nacsis',
              name => 'foo bar'
            response.should be_success
          end
        end

        describe "except_#{name}パラメータが指定されたとき" do
          it "否定形#{name.inspect}でNacsisCat.searchを実行すること" do
            nacsis_cat_should_receive_search_with(sname => ['foo', 'bar'], :except => {sname => ['baz']}, :db => :book)
            nacsis_cat_should_receive_search_with(sname => ['foo', 'bar'], :except => {sname => ['baz']}, :db => :serial)
            get :index, :index => 'nacsis',
              name => 'foo bar', :"except_#{name}" => 'baz'
            response.should be_success
          end
        end
      end
    end
  end

  describe ManifestationsController::NacsisCatSearch, :solr => false do
    it 'オブジェクト生成時に指定されたDBと異なるDB条件が与えられたら検索を実行せずに空の結果を返すこと' do
      search = ManifestationsController::NacsisCatSearch.new(:book)
      search.filter_by_record_type!('book')
      NacsisCat.should_receive(:search)
      search.execute

      search = ManifestationsController::NacsisCatSearch.new(:book)
      search.filter_by_record_type!('serial')
      NacsisCat.should_not_receive(:search)
      search.execute
    end

    {
      [:ncid, :isbn, :issn] => {
        'foo' => 'foo',
        '"foo"' => 'foo',
        "'foo'" => 'foo',
        ' foo ' => 'foo',
        '" foo "' => ' foo ',
        'foo bar' => 'foo bar',
        '"foo bar"' => 'foo bar',
        "foo'bar" => "foo'bar",
        'foo"bar' => 'foo"bar',
        'foo\\"bar' => 'foo"bar',
        '"foo\\"bar"' => 'foo"bar',
        '\\"foo' => '"foo',
        'foo\\"' => 'foo"',
      },
      [:query, :title, :creator, :publisher, :subject] => {
        'foo' => ['foo'],
        '"foo"' => ['foo'],
        "'foo'" => ['foo'],
        ' foo ' => ['foo'],
        '" foo "' => [' foo '],
        'foo bar' => ['foo', 'bar'],
        'foo  bar baz' => ['foo', 'bar', 'baz'],
        '"foo bar"' => ['foo bar'],
        'foo "bar baz" quux' => ['foo', 'bar baz', 'quux'],
        "foo'bar" => ["foo'bar"],
        'foo"bar' => ['foo"bar'],
        'foo\\"bar' => ['foo"bar'],
        '"foo\\"bar"' => ['foo"bar'],
        '\\"foo' => ['"foo'],
        '\\"foo bar' => ['"foo', 'bar'],
        'foo\\"' => ['foo"'],
        'foo bar\\"' => ['foo', 'bar"'],
      },
    }.each_pair do |names, tests|
      names.each do |name|
        pn = sn = name
        if name == :ncid
          sn = :id
        elsif name == :creator
          sn = :author
        end

        describe "\#filter_by_#{name}!は" do
          tests.each_pair do |pv, sv|
            it "入力値 #{pv} が与えられたとき #{sn.inspect} => #{sv.inspect} を検索条件に加えること" do
              NacsisCat.should_receive(:search) do |cond|
                cond[sn].should eq(sv),
                  "expected #{sn.inspect}=>#{sv.inspect}, but got #{sn.inspect}=>#{cond[sn].inspect}"
              end
              search = ManifestationsController::NacsisCatSearch.new
              search.__send__("filter_by_#{name}!", pv)
              search.execute
            end

            it "入力値 #{pv} が否定形で与えられたとき :except => {#{sn.inspect} => #{sv.inspect}} を検索条件に加えること" do
              NacsisCat.should_receive(:search) do |cond|
                cond[:except].should be_present,
                  "expected :except=>{#{sn.inspect}=>#{sv.inspect}}, but got :except=>nil"
                cond[:except][sn].should eq(sv),
                  "expected :except=>{#{sn.inspect}=>#{sv.inspect}}, but got :except=>{#{sn.inspect}=>#{cond[sn].inspect}}"
              end
              search = ManifestationsController::NacsisCatSearch.new
              search.__send__("filter_by_#{name}!", pv, true)
              search.execute
            end if sv.is_a?(Array) # NOTE: 複数文字列に対応した検索項目は否定形にも対応する
          end # tests.each_pair do
        end
      end # names.each do
    end # each_pair do

    describe '#per_pageは' do
      it '検索実行時に渡すper_pageオプションを室定すること' do
        NacsisCat.should_receive(:search).
          with(:per_page => 10, :page => 1, :db => :book).
          and_return(NacsisCat::ResultArray.new(nil))

        search = ManifestationsController::NacsisCatSearch.new(:book)
        search.per_page('10') # フォーム入力がそのまま渡るのでNacsisCatSearch#per_pageの引数は文字列となる(内部で数値に変換してNacsisCatに渡す)
        search.execute
      end
    end

    describe '#pageは' do
      it '検索実行時に渡すpageオプションを室定すること' do
        NacsisCat.should_receive(:search).
          with(:page => 2, :per_page => 10, :db => :book).
          and_return(NacsisCat::ResultArray.new(nil))

        search = ManifestationsController::NacsisCatSearch.new(:book)
        search.per_page('10')
        search.page('2') # フォーム入力がそのまま渡るのでNacsisCatSearch#pageの引数は文字列となる(内部で数値に変換してNacsisCatに渡す)
        search.execute
      end

      it 'per_pageの設定がなければ検索時に指定を無視すること' do
        NacsisCat.should_receive(:search).
          with(:db => :book).
          and_return(NacsisCat::ResultArray.new(nil))

        search = ManifestationsController::NacsisCatSearch.new(:book)
        search.page('2')
        search.execute
      end
    end
  end
end
