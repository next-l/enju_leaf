# encoding: utf-8
require 'spec_helper'

describe ManifestationsController do
  fixtures :all

  describe "GET index", :solr => true do
    # SystemConfigurationの簡易設定
    def update_system_configuration(key, value)
      Rails.cache.clear
      sc = SystemConfiguration.find_by_keyname(key)
      unless sc
        t = case value
            when String
              'String'
            when true, false
              'Boolean'
            when Fixnum
              'Numeric'
            end
        sc = SystemConfiguration.new(keyname: key, typename: t)
      end
      sc.v = value.to_s
      sc.save!
    end

    before do
      # キャッシュによる意図しない動作の回避のため
      # ManifestationsController#indexで使用している
      # SystemConfigurationを改めて設定しておく
      update_system_configuration('manifestation.manage_item_rank', true)
      update_system_configuration('manifestations.split_by_type', true)
      update_system_configuration('internal_server', true)
      update_system_configuration('max_number_of_results.use_and', 500)
      update_system_configuration('search.use_and', true)
      update_system_configuration('advanced_search.use_and', true)
      update_system_configuration('write_search_log_to_file', true)

      # searchブロックでエラーにならないよう
      # solrスキーマが最新状態すべくインデックスを更新しておく
      Sunspot.remove_all!
      Manifestation.first.index
      Sunspot.commit
    end

    after do
      Sunspot.remove_all!
      Rails.cache.clear
    end

    shared_examples_for 'manifestation search conditions' do
      before do
        # with(:foo).equal_to(:bar)のような呼び出しを追跡する
        #
        # たとえば
        #
        #   with(:foo); with(:bar).equal_to(:baz); with(:bar)
        #
        # と呼び出しがあったとき、@calledは
        #
        #   [[:with, :foo],
        #    [:with, :bar, [:baz]],
        #    [:with, :bar]]
        #
        # となる
        @called = []
        [:with, :without].each do |sym|
          Sunspot::DSL::Search.any_instance.stub(sym) do |*stub_arg|
            sub = [sym, stub_arg]
            def sub.method_missing(*args)
              self << args
            end
            @called << sub
            sub
          end
        end
      end

      # foo(bar)が呼び出されたことをチェックする場合: check_called(:foo, bar) (または check_called(:foo, [bar]))
      # foo(bar, baz)が呼び出されたことをチェックする場合: check_called(:foo, [bar, baz])
      # foo(bar).baz(quux)が呼び出されたことをチェックする場合: check_called(:foo, bar, :baz, quux)
      # foo(bar)が呼びだされたことだけをチェックし、それに続くメソッド呼び出しがあったかどうかはチェックしない場合: check_called(:foo, bar, :*)
      def check_called0(*expected_call)
        # expected_callに対応するメソッド呼び出しが
        # 少なくとも一回はあったことを検査する
        main_cond = [expected_call[0], [expected_call[1]].flatten]
        if expected_call.size == 3 && expected_call[2] == :*
          # with(:foo)がとにかく呼ばれたことだけを期待するとき
          # with(:foo)以降についてはチェックを行わない
          subs_check = proc {|subs| true }
        elsif expected_call.size > 2
          # with(:foo).equal_to(:bar)が期待されたときの
          # equal_to(:bar)に対するチェック
          subs_check = proc {|subs| subs.any? {|sub| sub == expected_call[2 .. -1] } }
        else
          # with(:foo)が期待されたときの
          # with()以降に何もきてないことに対するチェック
          subs_check = proc {|subs| subs == [] }
        end

        @called.any? {|cond, field, *subs|
          [cond, field] == main_cond && subs_check.call(subs)
        }
      end

      def check_called(*expected_call)
        method_str = check_called_method_str(*expected_call)
        check_called0(*expected_call).should be_true, "\"#{method_str}\" did not call"
      end

      def check_not_called(*expected_call)
        method_str = check_called_method_str(*expected_call)
        check_called0(*expected_call).should be_false, "\"#{method_str}\" called"
      end

      def self.check_called_method_str(*expected_call)
        method_str = "#{expected_call[0]}(#{expected_call[1].inspect})"
        if expected_call[2] && expected_call[2] != :*
          method_str << ".#{expected_call[2]}"
          method_str << "(#{expected_call[3..-1].map(&:inspect).join(', ')})" if expected_call[3]
        end
        method_str
      end
      def check_called_method_str(*expected_call)
        self.class.check_called_method_str(*expected_call)
      end

      after do
        check_called(*@expected_call) if @expected_call.present?
      end
    end

    shared_examples_for 'index should load records' do
      [
        # param name, expected record, ivar name, [search condition spec]
        [:patron_id, Patron, :patron,
          [:with, :publisher_ids, :equal_to, :id]],
        [:series_statement_id, SeriesStatement, :series_statement,
          [:with, :series_statement_id, :equal_to, :id]],
        [:manifestation_id, Manifestation, :manifestation,
          [:with, :original_manifestation_ids, :equal_to, :id]],
        [:subject_id, Subject, :subject,
          [:with, :subject_ids, :equal_to, :id]],
        [:patron_id, Patron, :index_patron, :patron],
        [:creator_id, Patron, :index_patron, :creator,
          [:with, :creator_ids, :equal_to, :id]],
        [:contributor_id, Patron, :index_patron, :contributor,
          [:with, :contributor_ids, :equal_to, :id]],
        [:publisher_id, Patron, :index_patron, :publisher,
          [:with, :publisher_ids, :equal_to, :id]],
      ].each do |psym, cls, *dst|
        expected_call_base = dst.pop if dst.last.is_a?(Array)
        ivar, idx = dst

        context "When #{psym} param is specified" do
          include_examples 'manifestation search conditions'

          it "should load a #{cls.name} record as @#{ivar} and use it as a solr search condition" do
            expected = cls.first
            if expected_call_base.blank?
              @expected_call = nil
            else
              sym = expected_call_base.pop
              @expected_call = expected_call_base + [expected.__send__(sym)]
            end

            get :index, psym => expected.id.to_s

            response.should be_success
            assigns(ivar).should be_present
            if idx
              assigns(ivar)[idx].should eq(expected)
            else
              assigns(ivar).should eq(expected)
            end
          end
        end
      end

      context "When bookbinder_id param is specified" do
        include_examples 'manifestation search conditions'

        it 'should load first Item record of a Manifestation record and use it as a solr search condition' do
          manifestation = Manifestation.first
          expected = manifestation.items.first

          get :index, :bookbinder_id => manifestation.id.to_s

          response.should be_success
          assigns(:binder).should be_present
          assigns(:binder).should eq(expected)

          check_called(:with, :bookbinder_id, :equal_to, expected.id)
          check_called(:without, [:id, manifestation.id])
        end

        it 'should set nil to @binder and not touch solr search conditions if bookbinder_id is invalid' do
          invalid_id = Manifestation.last.id + 100

          get :index, :bookbinder_id => invalid_id.to_s

          response.should be_success
          assigns(:binder).should be_nil

          check_not_called(:with, :bookbinder_id, :*)
          check_not_called(:without, :id, :*)
        end
      end
    end

    shared_examples_for 'index should set search conditions according to params' do
      [
        ['subject', [
          ['next-l',         :check_called,     [:with, :subject, :equal_to, 'next-l']],
          ['not exist term', :check_called,     [:with, :subject, :equal_to, nil]],
          [nil,              :check_not_called, [:with, :subject, :*]],
        ]],
        ['removed', [
          ['true', :check_called,     [:with, :has_removed, :equal_to, true]],
          ['true', :check_not_called, [:without, :non_searchable, :*]],
          [nil,    :check_not_called, [:with, :has_removed, :*]],
        ]],
        ['removed_from', [
          ['2013', :check_called,     [:with, :has_removed, :equal_to, true]],
          [nil,    :check_not_called, [:with, :has_removed, :*]],
        ]],
        ['removed_to', [
          ['2013', :check_called,     [:with, :has_removed, :equal_to, true]],
          [nil,    :check_not_called, [:with, :has_removed, :*]],
        ]],
        ['reservable', [
          ['true',  :check_called,     [:with, :reservable, :equal_to, true]],
          ['false', :check_called,     [:with, :reservable, :equal_to, false]],
          [nil,     :check_not_called, [:with, :reservable, :*]],
        ]],
        ['carrier_type', [
          ['foo', :check_called,     [:with, :carrier_type, :equal_to, 'foo']],
          [nil,   :check_not_called, [:with, :carrier_type, :*]],
        ]],
        ['library', [
          ['foo',     :check_called,     [:with, :library, :equal_to, 'foo']],
          ['foo bar', :check_called,     [:with, :library, :equal_to, 'foo'],
                                         [:with, :library, :equal_to, 'bar']],
          [nil,       :check_not_called, [:with, :library, :*]],
        ]],
        ['language', [
          ['foo',     :check_called,     [:with, :language, :equal_to, 'foo']],
          ['foo bar', :check_called,     [:with, :language, :equal_to, 'foo'],
                                         [:with, :language, :equal_to, 'bar']],
          [nil,       :check_not_called, [:with, :language, :*]],
        ]],
        ['missing_issue', [
          ['1', :check_called,     [:with, :missing_issue, :equal_to, '1']], # XXX: 意味合いとしては1が正しそう
          [nil, :check_not_called, [:with, :missing_issue, :*]],
          [nil, :check_called,     [:without, :non_searchable, :equal_to, true]],
        ]],
        ['all_manifestations', [
          ['true', :check_not_called, [:without, :non_searchable, :*]],
          [nil,    :check_called,     [:without, :non_searchable, :equal_to, true]],
        ]],
        ['series_statement_id', [
          ['1', :check_called,     [:with, :periodical_master, :equal_to, false]],
          ['1', :check_not_called, [:with, :periodical, :*]],
          [nil, :check_not_called, [:with, :periodical_master, :*]],
          [nil, :check_called,     [:with, :periodical, :equal_to, false]],
        ]],
      ].each do |param, specs|
        specs.each do |pvalue, check, *check_args|
          t = pvalue.nil? ? "no #{param}" : "#{param}=#{pvalue.to_s}"
          context "When #{t} is specified" do
            include_examples 'manifestation search conditions'
            t1 = check == :check_not_called ? 'not call' : 'call'
            check_args.each do |ca|
              t2 = check_called_method_str(*ca)
              it "should #{t1} #{t2}" do
                get :index, param => pvalue
                response.should be_success
                __send__(check, *ca)
              end
            end
          end
        end
      end
    end

    shared_examples_for 'index can get a collation' do
      describe "When no record found" do
        let(:exact_title) { "RailsによるアジャイルWebアプリケーション開発" }
        let(:typo_title)  { "RailsによるアジイャルWebアプリケーション開発" }

        before do
          Sunspot.remove_all!

          @manifestation = FactoryGirl.create(
            :manifestation,
            :original_title => exact_title,
            :manifestation_type => FactoryGirl.create(:manifestation_type))
          @item = FactoryGirl.create(
            :item_book,
            :retention_period => FactoryGirl.create(:retention_period),
            :manifestation => @manifestation)

          Sunspot.commit
        end

        it "assigns a collation as @collation" do
          get :index, :query => typo_title, :all_manifestations => 'true'
          assigns(:manifestations).should be_empty
          assigns(:collation).should be_present
          assigns(:collation).should == [exact_title]
        end

        it "doesn't assign @collation" do
          get :index, :query => exact_title, :all_manifestations => 'true'
          assigns(:manifestations).should be_present
          assigns(:collation).should be_blank
        end
      end
    end

    shared_examples_for 'index should set is_article search conditions' do
      describe 'For split-by-type search' do
        include_examples 'manifestation search conditions'

        it 'should search with/without is_article' do
          get :index
          check_called(:with,    :is_article, :equal_to, false)
          check_called(:without, :is_article, :equal_to, false)
        end
      end
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all manifestations as @manifestations" do
        get :index
        assigns(:manifestations).should_not be_nil
      end

      include_examples 'index should load records'
      include_examples 'index should set search conditions according to params'
      include_examples 'index can get a collation'
      include_examples 'index should set is_article search conditions'
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all manifestations as @manifestations" do
        get :index
        assigns(:manifestations).should_not be_nil
      end

      it "should set true to @add if mode parameter is 'add'" do
        get :index, mode: 'add'
        response.should be_success
        assigns(:add).should be_true
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all manifestations as @manifestations" do
        get :index
        assigns(:manifestations).should_not be_nil
      end

      it "should be deny access if mode parameter is 'add'" do
        get :index, mode: 'add'
        response.should be_forbidden
        assigns(:add).should be_blank
      end
    end

    describe "When not logged in" do
      it "assigns all manifestations as @manifestations" do
        get :index
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations in sru format without operation" do
        search_called = false
        Manifestation.stub(:search) { search_called = true }
        Sunspot.stub(:new_search) { search_called = true }

        get :index, :format => 'sru'
        assert_response :success
        assigns(:manifestations).should be_nil
        response.should render_template('manifestations/explain')

        search_called.should be_false
      end

      it "assigns all manifestations as @manifestations in sru format with operation" do
        get :index, :format => 'sru', :operation => 'searchRetrieve', :query => 'ruby'
        assigns(:manifestations).should_not be_nil
        response.should render_template('manifestations/index')
      end

      it "assigns all manifestations as @manifestations in sru format with operation and title" do
        get :index, :format => 'sru', :query => 'title=ruby', :operation => 'searchRetrieve'
        assigns(:manifestations).should_not be_nil
        response.should render_template('manifestations/index')
      end

      it "assigns all manifestations as @manifestations in openurl" do
        get :index, :api => 'openurl', :title => 'ruby'
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations when pub_date_from and pub_date_to are specified" do
        get :index, :pub_date_from => '2000', :pub_date_to => '2007'
        assigns(:query).should eq "pub_date_sm:[#{Time.zone.parse('2000-01-01').utc.iso8601} TO #{Time.zone.parse('2007-12-31').end_of_year.utc.iso8601}]"
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations when acquired_from and pub_date_to are specified" do
        get :index, :acquired_from => '2000', :acquired_to => '2007'
        assigns(:query).should eq "acquired_at_sm:[#{Time.zone.parse('2000-01-01').utc.iso8601} TO #{Time.zone.parse('2007-12-31').end_of_day.utc.iso8601}]"
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations when number_of_pages_at_least and number_of_pages_at_most are specified" do
        get :index, :number_of_pages_at_least => '100', :number_of_pages_at_least => '200'
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations in mods format" do
        get :index, :format => 'mods'
        assigns(:manifestations).should_not be_nil
        response.should render_template("manifestations/index")
      end

      it "assigns all manifestations as @manifestations in rdf format" do
        get :index, :format => 'rdf'
        assigns(:manifestations).should_not be_nil
        response.should render_template("manifestations/index")
      end

      it "assigns all manifestations as @manifestations in oai format without verb" do
        get :index, :format => 'oai'
        assigns(:manifestations).should_not be_nil
        assigns(:oai).should be_present
        response.should render_template("manifestations/index")
      end

      it "assigns all manifestations as @manifestations in oai format with ListRecords" do
        get :index, :format => 'oai', :verb => 'ListRecords'
        assigns(:manifestations).should_not be_nil
        assigns(:oai).should be_present
        response.should render_template("manifestations/list_records")
      end

      it "assigns all manifestations as @manifestations in oai format with ListIdentifiers" do
        get :index, :format => 'oai', :verb => 'ListIdentifiers'
        assigns(:manifestations).should_not be_nil
        assigns(:oai).should be_present
        response.should render_template("manifestations/list_identifiers")
      end

      it "assigns all manifestations as @manifestations in oai format with GetRecord without identifier" do
        search_called = false
        Manifestation.stub(:search) { search_called = true }
        Sunspot.stub(:new_search) { search_called = true }

        get :index, :format => 'oai', :verb => 'GetRecord'
        assigns(:manifestations).should be_nil
        assigns(:manifestation).should be_nil
        assigns(:oai).should be_present
        response.should render_template('manifestations/index')

        search_called.should be_false
      end

      it "assigns all manifestations as @manifestations in oai format with GetRecord with identifier" do
        search_called = false
        Manifestation.stub(:search) { search_called = true }
        Sunspot.stub(:new_search) { search_called = true }

        get :index, :format => 'oai', :verb => 'GetRecord', :identifier => 'oai:localhost:manifestations-1'
        assigns(:manifestations).should be_nil
        assigns(:manifestation).should_not be_nil
        assigns(:oai).should be_present
        response.should render_template('manifestations/show')

        search_called.should be_false
      end

      describe 'With more than two query texts' do
        before do
          Sunspot.remove_all!
          Manifestation.all.map(&:index)
          Sunspot.commit
        end

        it 'should search manifestations that satisfies all parameters when search.use_and is true' do
          update_system_configuration('search.use_and', 'true')

          get :index, query: 'creator_text:Librarian1 publisher_text:Administrator', all_manifestations: 'true'
          response.should be_success
          assigns(:manifestations).should have(1).item
          assigns(:manifestations).should include(manifestations(:manifestation_00001))
        end

        it 'should search manifestations that satisfies any parameters when search.use_and is false' do
          update_system_configuration('search.use_and', 'false')

          get :index, query: 'creator_text:Librarian1 publisher_text:Administrator', all_manifestations: 'true'
          response.should be_success
          assigns(:manifestations).should have(4).items
          assigns(:manifestations).should include(manifestations(:manifestation_00001))
          assigns(:manifestations).should include(manifestations(:manifestation_00002))
          assigns(:manifestations).should include(manifestations(:manifestation_00004))
          assigns(:manifestations).should include(manifestations(:manifestation_00005))
        end

        it 'should search manifestations that satisfies all parameters when advanced_search.use_and is true' do
          update_system_configuration('advanced_search.use_and', 'true')

          get :index, creator: 'Librarian1', publisher: 'Administrator', all_manifestations: 'true'
          response.should be_success
          assigns(:manifestations).should have(1).item
          assigns(:manifestations).should include(manifestations(:manifestation_00001))
        end

        it 'should search manifestations that satisfies any parameters when advanced_search.use_and is false' do
          update_system_configuration('advanced_search.use_and', 'false')

          get :index, creator: 'Librarian1', publisher: 'Administrator', all_manifestations: 'true'
          response.should be_success
          assigns(:manifestations).should have(4).items
          assigns(:manifestations).should include(manifestations(:manifestation_00001))
          assigns(:manifestations).should include(manifestations(:manifestation_00002))
          assigns(:manifestations).should include(manifestations(:manifestation_00004))
          assigns(:manifestations).should include(manifestations(:manifestation_00005))
        end

        it 'should search manifestations that satisifes parameters including white-spaces' do
          get :index, creator: 'Librarian1 Administrator', all_manifestations: 'true'
          response.should be_success
          assigns(:manifestations).should have(0).items
        end
      end

      describe 'result order' do
        [
          ['title', %w(sort_title asc)],
          ['pub_date', %w(date_of_publication desc)],
          ['carrier_type', %w(carrier_type desc)],
          ['author', %w(author asc)],
          [nil, %w(created_at desc)]
        ].each do |param, order_args|
          ['asc', 'desc', nil].each do |dir|
            expected_args = [order_args[0], dir ? dir : order_args[1]]
            it "should be \"#{order_args.join(' ')}\" with sort_by=#{param.inspect} and order=#{dir.inspect}" do
              called = []
              expected = [expected_args, [:created_at, :desc]]*3
              Sunspot::DSL::Search.any_instance.stub(:order_by) do |*args|
                called << args
              end

              get :index, sort_by: param.to_s, order: dir.to_s

              unexpected = called - expected
              unexpected.should be_blank, "unexpected order_by call: #{unexpected.map {|x| x.join(' ') }.join(', ')}"
              called.should eq(expected)
            end
          end
        end

        it 'should be done by and updated_at in oai format' do
          called = []
          expected = [[:updated_at, :desc]]*3
          Sunspot::DSL::Search.any_instance.stub(:order_by) do |*args|
            called << args
          end

          get :index, format: 'oai'

          unexpected = called - expected
          unexpected.should be_blank, "unexpected order_by call: #{unexpected.map {|x| x.join(' ') }.join(', ')}"
          called.should eq(expected)
        end
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        assigns(:manifestation).should eq(Manifestation.find(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        assigns(:manifestation).should eq(Manifestation.find(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        assigns(:manifestation).should eq(Manifestation.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        assigns(:manifestation).should eq(Manifestation.find(1))
      end

      it "guest should show manifestation mods template" do
        get :show, :id => 22, :format => 'mods'
        assigns(:manifestation).should eq Manifestation.find(22)
        response.should render_template("manifestations/show")
      end

      it "should show manifestation rdf template" do
        get :show, :id => 22, :format => 'rdf'
        assigns(:manifestation).should eq Manifestation.find(22)
        response.should render_template("manifestations/show")
      end

      it "should_show_manifestation_with_isbn" do
        get :show, :isbn => "4798002062"
        response.should redirect_to manifestation_url(assigns(:manifestation))
      end

      it "should_show_manifestation_with_isbn" do
        get :show, :isbn => "47980020620"
        response.should be_missing
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested manifestation as @manifestation" do
        get :new
        assigns(:manifestation).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested manifestation as @manifestation" do
        get :new
        assigns(:manifestation).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested manifestation as @manifestation" do
        get :new
        assigns(:manifestation).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested manifestation as @manifestation" do
        get :new
        assigns(:manifestation).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested manifestation as @manifestation" do
        manifestation = FactoryGirl.create(:manifestation)
        get :edit, :id => manifestation.id
        assigns(:manifestation).should eq(manifestation)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested manifestation as @manifestation" do
        manifestation = FactoryGirl.create(:manifestation)
        get :edit, :id => manifestation.id
        assigns(:manifestation).should eq(manifestation)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested manifestation as @manifestation" do
        manifestation = FactoryGirl.create(:manifestation)
        get :edit, :id => manifestation.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested manifestation as @manifestation" do
        manifestation = FactoryGirl.create(:manifestation)
        get :edit, :id => manifestation.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:manifestation)
      @invalid_attrs = {:original_title => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created manifestation as @manifestation" do
          post :create, :manifestation => @attrs
          assigns(:manifestation).should be_valid
        end

        it "redirects to the created manifestation" do
          post :create, :manifestation => @attrs
          response.should redirect_to(manifestation_url(assigns(:manifestation)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation as @manifestation" do
          post :create, :manifestation => @invalid_attrs
          assigns(:manifestation).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :manifestation => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created manifestation as @manifestation" do
          post :create, :manifestation => @attrs
          assigns(:manifestation).should be_valid
        end

        it "redirects to the created manifestation" do
          post :create, :manifestation => @attrs
          response.should redirect_to(manifestation_url(assigns(:manifestation)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation as @manifestation" do
          post :create, :manifestation => @invalid_attrs
          assigns(:manifestation).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :manifestation => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created manifestation as @manifestation" do
          post :create, :manifestation => @attrs
          assigns(:manifestation).should be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation as @manifestation" do
          post :create, :manifestation => @invalid_attrs
          assigns(:manifestation).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created manifestation as @manifestation" do
          post :create, :manifestation => @attrs
          assigns(:manifestation).should be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation as @manifestation" do
          post :create, :manifestation => @invalid_attrs
          assigns(:manifestation).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @manifestation = FactoryGirl.create(:manifestation)
      @attrs = FactoryGirl.attributes_for(:manifestation)
      @invalid_attrs = {:original_title => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
        end

        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
          assigns(:manifestation).should eq(@manifestation)
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
        end

        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
          assigns(:manifestation).should eq(@manifestation)
          response.should redirect_to(@manifestation)
        end
      end

      describe "with invalid params" do
        it "assigns the manifestation as @manifestation" do
          put :update, :id => @manifestation, :manifestation => @invalid_attrs
          assigns(:manifestation).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @manifestation, :manifestation => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
        end

        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
          assigns(:manifestation).should eq(@manifestation)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @manifestation = FactoryGirl.create(:manifestation)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested manifestation" do
        delete :destroy, :id => @manifestation.id
      end

      it "redirects to the manifestations list" do
        delete :destroy, :id => @manifestation.id
        response.should redirect_to(manifestations_url)
      end

      it "should not destroy the reserved manifestation" do
        delete :destroy, :id => 2
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested manifestation" do
        delete :destroy, :id => @manifestation.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @manifestation.id
        response.should redirect_to(manifestations_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested manifestation" do
        delete :destroy, :id => @manifestation.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @manifestation.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested manifestation" do
        delete :destroy, :id => @manifestation.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @manifestation.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
