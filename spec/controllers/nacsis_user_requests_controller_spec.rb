# encoding: utf-8
require 'spec_helper'

describe NacsisUserRequestsController do
  include NacsisCatSpecHelper

  fixtures :all

  let(:record_type) { :book }
  let(:nacsis_cat) { nacsis_cat_with_mock_record(record_type) }
  let(:ncid) { nacsis_cat.record['ID'] }

  shared_context '管理ユーザでログインする' do
    let(:login_user) {
      FactoryGirl.create(:librarian)
    }
  end

  shared_context '一般ユーザでログインする' do
    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:login_user) { user1 }
    let(:other_user) { user2 }
  end

  include_context '管理ユーザでログインする'
  before do
    sign_in login_user
  end

  describe '#indexは', :solr => true do
    it '@nacsis_user_requestsにNacsisUserRequestレコードのリストを設定すること' do
      nacsis_user_request = FactoryGirl.create(:nacsis_user_request)
      Sunspot.commit
      get :index, {}
      expect(assigns(:nacsis_user_requests)).to eq([nacsis_user_request])
    end

    it '@nacsis_user_request_searchに検索結果を設定すること' do
      get :index, {}
      expect(assigns(:nacsis_user_request_search)).to be_present
    end

    it '依頼分類および状態をfacetに指定すること' do
      get :index, {}
      search = assigns(:nacsis_user_request_search)
      expect(search.facet(:request_type)).to be_present
      expect(search.facet(:state)).to be_present
    end

    describe '状態条件が' do
      before do
        @nacsis_user_requests = {}
        NacsisUserRequest::VALID_STATES.each do |state|
          @nacsis_user_requests[state] =
            FactoryGirl.create(:nacsis_user_request, :state => state)
        end
        Sunspot.commit
      end

      NacsisUserRequest::VALID_STATES.each do |state|
        describe "#{state}と指定されたとき" do
          it "状態が#{state}であるレコードだけ@nacsis_user_requestsにロードすること" do
            get :index, {'state' => state.to_s}
            expect(assigns(:nacsis_user_requests)).to eq([@nacsis_user_requests[state]])
          end
        end
      end

      describe '不正な指定であったとき' do
        it '@nacsis_user_requestsを空にすること' do
          get :index, {'state' => 'abc'}
          expect(assigns(:nacsis_user_requests)).to be_blank
        end
      end

      describe '複数個指定されたとき' do
        it 'いずれかの状態であるレコードだけを@nacsis_user_requestsにロードすること' do
            get :index, {'state' => %w(1 3)}
            nacsis_user_requests = assigns(:nacsis_user_requests)
            expect(nacsis_user_requests).to include(@nacsis_user_requests[1])
            expect(nacsis_user_requests).to include(@nacsis_user_requests[3])
            expect(nacsis_user_requests.size).to eq(2)
        end

        it '不正な値が含まれていたらそれらを無視すること' do
            get :index, {'state' => %w(1 -3 abc)}
            nacsis_user_requests = assigns(:nacsis_user_requests)
            expect(nacsis_user_requests).to include(@nacsis_user_requests[1])
            expect(nacsis_user_requests.size).to eq(1)
        end

        it 'すべて不正な値であったら@nacsis_user_requestsを空にすること' do
            get :index, {'state' => %w(-1 -3 abc)}
            nacsis_user_requests = assigns(:nacsis_user_requests)
            expect(nacsis_user_requests).to be_blank
        end
      end
    end

    describe '依頼分類条件が' do
      before do
        @nacsis_user_requests = {}
        NacsisUserRequest::VALID_REQUEST_TYPES.each do |request_type|
          @nacsis_user_requests[request_type] =
            FactoryGirl.create(:nacsis_user_request, :request_type => request_type)
        end
        Sunspot.commit
      end

      NacsisUserRequest::VALID_REQUEST_TYPES.each do |request_type|
        describe "#{request_type}と指定されたとき" do
          it "依頼分類が#{request_type}であるレコードだけ@nacsis_user_requestsにロードすること" do
            get :index, {'request_type' => [request_type.to_s]}
            expect(assigns(:nacsis_user_requests)).to eq([@nacsis_user_requests[request_type]])
          end
        end
      end

      describe '不正な指定であったとき' do
        it '@nacsis_user_requestsを空にすること' do
          get :index, {'request_type' => ['abc']}
          expect(assigns(:nacsis_user_requests)).to be_blank
        end
      end

      describe '複数個指定されたとき' do
        it 'いずれかの依頼分類であるレコードだけを@nacsis_user_requestsにロードすること' do
            get :index, {'request_type' => %w(1 2)}
            nacsis_user_requests = assigns(:nacsis_user_requests)
            expect(nacsis_user_requests).to include(@nacsis_user_requests[1])
            expect(nacsis_user_requests).to include(@nacsis_user_requests[2])
            expect(nacsis_user_requests.size).to eq(2)
        end

        it '不正な値が含まれていたらそれらを無視すること' do
            get :index, {'request_type' => %w(1 -3 abc)}
            nacsis_user_requests = assigns(:nacsis_user_requests)
            expect(nacsis_user_requests).to include(@nacsis_user_requests[1])
            expect(nacsis_user_requests.size).to eq(1)
        end

        it 'すべて不正な値であったら@nacsis_user_requestsを空にすること' do
            get :index, {'request_type' => %w(-1 -3 abc)}
            nacsis_user_requests = assigns(:nacsis_user_requests)
            expect(nacsis_user_requests).to be_blank
        end
      end
    end

    describe 'NCID条件が与えられたとき' do
      before do
        @nacsis_user_requests = {}
        %w(foo1 bar2).each do |ncid|
          @nacsis_user_requests[ncid] =
            FactoryGirl.create(:nacsis_user_request, :ncid => ncid)
        end
        Sunspot.commit
      end

      it 'NCIDが完全一致するレコードだけを@nacsis_user_requestsにロードすること' do
        ncid = 'foo1'
        get :index, {'ncid' => ncid}
        nacsis_user_requests = assigns(:nacsis_user_requests)
        expect(nacsis_user_requests).to include(@nacsis_user_requests[ncid])
        expect(nacsis_user_requests.size).to eq(1)
      end

      it 'NCIDが完全一致するレコードがなければ@nacsis_user_requestsを空にすること' do
        get :index, {'ncid' => 'foo'}
        expect(assigns(:nacsis_user_requests)).to be_blank
      end
    end

    describe 'レコード作成日時条件が与えられたとき' do
      before do
        @nacsis_user_requests = {}
        [
          Time.local(2013, 6, 1, 12, 0, 0),
          Time.local(2013, 6, 2, 12, 0, 0),
          Time.local(2013, 6, 3, 12, 0, 0),
        ].each do |time|
          key = time.strftime('%Y-%m-%d')
          record = FactoryGirl.create(:nacsis_user_request)
          record.created_at = time
          record.save!
          @nacsis_user_requests[key] = record
        end
        Sunspot.commit
      end

      it '範囲に含まれるレコードだけを@nacsis_user_requestsにロードすること' do
        get :index, {'created_from' => '2013-06-02', 'created_to' => '2013-06-03'}
        nacsis_user_requests = assigns(:nacsis_user_requests)
        expect(nacsis_user_requests).to be_present
        expect(nacsis_user_requests).to include(@nacsis_user_requests['2013-06-02'])
        expect(nacsis_user_requests).to include(@nacsis_user_requests['2013-06-03'])
        expect(nacsis_user_requests.size).to eq(2)
      end

      it '範囲に含まれるレコードだけがなければ@nacsis_user_requestsを空にすること' do
        get :index, {'created_from' => '2013-05-01', 'created_to' => '2013-05-31'}
        nacsis_user_requests = assigns(:nacsis_user_requests)
        expect(nacsis_user_requests).to be_blank
      end

      it '始端と終端が同じ日にちなら同日中に作成されたレコードだけを@nacsis_user_requestsにロードすること' do
        get :index, {'created_from' => '2013-06-02', 'created_to' => '2013-06-02'}
        nacsis_user_requests = assigns(:nacsis_user_requests)
        expect(nacsis_user_requests).to be_present
        expect(nacsis_user_requests).to include(@nacsis_user_requests['2013-06-02'])
        expect(nacsis_user_requests.size).to eq(1)
      end

      it '始端のみの指定なら始端日時以降に作成されたレコードだけを@nacsis_user_requestsにロードすること' do
        get :index, {'created_from' => '2013-06-02'}
        nacsis_user_requests = assigns(:nacsis_user_requests)
        expect(nacsis_user_requests).to be_present
        expect(nacsis_user_requests).to include(@nacsis_user_requests['2013-06-02'])
        expect(nacsis_user_requests).to include(@nacsis_user_requests['2013-06-03'])
        expect(nacsis_user_requests.size).to eq(2)
      end

      it '終端のみの指定なら終端日時以前に作成されたレコードだけを@nacsis_user_requestsにロードすること' do
        get :index, {'created_to' => '2013-06-02'}
        nacsis_user_requests = assigns(:nacsis_user_requests)
        expect(nacsis_user_requests).to be_present
        expect(nacsis_user_requests).to include(@nacsis_user_requests['2013-06-01'])
        expect(nacsis_user_requests).to include(@nacsis_user_requests['2013-06-02'])
        expect(nacsis_user_requests.size).to eq(2)
      end

      it '範囲の始端が不正であったら@nacsis_user_requestsを空にすること' do
        get :index, {'created_from' => '2013-06-01', 'created_to' => 'XYZ'}
        nacsis_user_requests = assigns(:nacsis_user_requests)
        expect(nacsis_user_requests).to be_blank
      end

      it '範囲の終端が不正であったら@nacsis_user_requestsを空にすること' do
        get :index, {'created_from' => 'XYZ', 'created_to' => '2013-06-02'}
        nacsis_user_requests = assigns(:nacsis_user_requests)
        expect(nacsis_user_requests).to be_blank
      end
    end

    describe '本表題・責任表示条件が与えられたとき' do
      before do
        str = 'NACSIS利用者リクエスト情報'
        @nacsis_user_requests = {}
        [:subject_heading, :publisher, :author_heading].each do |sym|
          @nacsis_user_requests[sym] =
            FactoryGirl.create(:nacsis_user_request, sym => str)
        end
        Sunspot.commit
      end

      it '標目または著者情報が部分一致するレコードを@nacsis_user_requestsにロードすること' do
        get :index, {'query' => '利用者リクエスト'}
        nacsis_user_requests = assigns(:nacsis_user_requests)
        expect(nacsis_user_requests).to be_present
        expect(nacsis_user_requests).to include(@nacsis_user_requests[:subject_heading])
        expect(nacsis_user_requests).to include(@nacsis_user_requests[:author_heading])
        expect(nacsis_user_requests.size).to eq(2)
      end

      it '条件が一文字だけなら前方一致するレコードを@nacsis_user_requestsにロードすること' do
        record = @nacsis_user_requests[:publisher]
        record.subject_heading = '私の名前は中野です'
        record.save!
        Sunspot.commit

        get :index, {'query' => '私'}
        nacsis_user_requests = assigns(:nacsis_user_requests)
        expect(nacsis_user_requests).to be_present
        expect(nacsis_user_requests).to include(record)
        expect(nacsis_user_requests.size).to eq(1)
      end
    end

    describe 'ページネイト処理により' do
      let(:total_count) { 4 }
      let(:default_per_page) { 2 }

      before do
        @save_default_per_page = NacsisUserRequest.default_per_page
        NacsisUserRequest.paginates_per default_per_page

        @nacsis_user_requests =
          total_count.times.map { FactoryGirl.create(:nacsis_user_request) }
        Sunspot.commit
      end

      after do
        NacsisUserRequest.paginates_per @save_default_per_page
      end

      it '@nacsis_user_requestsに既定数までのレコードをロードすること' do
        get :index, {}
        nacsis_user_requests = assigns(:nacsis_user_requests)
        expect(nacsis_user_requests).to be_present
        expect(nacsis_user_requests).to have(default_per_page).items
        expect(nacsis_user_requests.total_count).to eq(total_count)
      end

      it 'per_pageパラメータ指定された数までのレコードを@nacsis_user_requestsにロードすること' do
        get :index, {'per_page' => default_per_page + 1}
        nacsis_user_requests = assigns(:nacsis_user_requests)
        expect(nacsis_user_requests).to be_present
        expect(nacsis_user_requests).to have(default_per_page + 1).items
        expect(nacsis_user_requests.total_count).to eq(total_count)
      end

      it '@nacsis_user_requestsに1ページ目のレコードをロードすること' do
        get :index, {}
        nacsis_user_requests = assigns(:nacsis_user_requests)
        expect(nacsis_user_requests).to be_present
        expect(nacsis_user_requests).to eq(@nacsis_user_requests[0, default_per_page])
      end

      it 'pageパラメータで指定されたページのレコードを@nacsis_user_requestsにロードすること' do
        get :index, {'page' => 2}
        nacsis_user_requests = assigns(:nacsis_user_requests)
        expect(nacsis_user_requests).to be_present
        expect(nacsis_user_requests).to eq(@nacsis_user_requests[default_per_page, default_per_page])
      end
    end

    describe 'ソート処理により' do
      let(:sorted_attr_list) { {
        'subject_heading' => %w(abc/abc abc/xyz def/abc ghi/abc ghi/xyz),
        'request_type' => [1, 2],
        'state' => [1, 2, 3],
        'created_at' => [Time.local(2013, 6, 1), Time.local(2013, 6, 2), Time.local(2013, 6, 3)],
        'user_number' => %w(abc def ghi),
      } }

      ['subject_heading', 'request_type', 'state', 'created_at', 'user_number'].each do |field_param|
        ['asc', 'desc', nil].each do |order_param|
          title = "sortパラメータで#{field_param}が指定され、"
          if order_param.present?
            title << "sort_byパラメータで#{order_param}が指定されたとき、"
            order = order_param
          else
            title << "sort_byパラメータが無指定のとき、"
            order = 'asc'
          end
          order_txt = order == 'asc' ? '昇順' : '降順'

          it "#{title}#{field_param}を#{order_txt}で並べ替えること" do
            sorted = sorted_attr_list[field_param]
            first_record = last_record = nil

            # 必要なレコードの作成
            sorted.shuffle.each do |value|
              case field_param
              when 'created_at'
                # 後でcreated_atを設定する
                attrs = {}
              when 'user_number'
                # 必要なuser_numberを持ったuserを設定する
                user = FactoryGirl.create(:librarian)
                user.user_number = value
                user.save!
                attrs = {'user_id' => user.id}
              else
                # 各フィールドの値を設定する
                attrs = {field_param => value}
              end

              record = FactoryGirl.create(:nacsis_user_request, attrs)
              if field_param == 'created_at'
                record.created_at = value
                record.save!
              end

              if value == sorted.first
                first_record = record # 昇順の場合の先頭レコード
              elsif value == sorted.last
                last_record = record # 昇順の場合の末尾レコード
              end
            end
            Sunspot.commit

            get :index, {'sort_by' => field_param, 'sort' => order_param}

            nacsis_user_requests = assigns(:nacsis_user_requests)
            expect(nacsis_user_requests).to be_present
            expect(nacsis_user_requests.first).to eq(order == 'asc' ? first_record : last_record)
            expect(nacsis_user_requests.last).to eq(order == 'asc' ? last_record : first_record)
          end
        end
      end
    end

    describe '一般ユーザでログインしているとき' do
      include_context '一般ユーザでログインする'
      before do
        FactoryGirl.create(:nacsis_user_request, :user => login_user)
        FactoryGirl.create(:nacsis_user_request, :user => other_user)
        Sunspot.commit
      end

      it '他人のNacsisUserRequestレコードを取得しないこと' do
        get :index, {}
        nacsis_user_requests = assigns(:nacsis_user_requests)
        expect(nacsis_user_requests).to be_present
        expect(nacsis_user_requests).to be_all {|x| x.user == login_user }
      end
    end
  end

  describe '#showは' do
    it 'idパラメータで指定されたレコードを@nacsis_user_requestにロードすること' do
      nacsis_user_request = FactoryGirl.create(:nacsis_user_request)
      get :show, {:id => nacsis_user_request.to_param}
      expect(assigns(:nacsis_user_request)).to eq(nacsis_user_request)
    end

    describe '一般ユーザでログインしているとき' do
      include_context '一般ユーザでログインする'

      it '他人のNacsisCatレコードにアクセスさせないこと' do
        nacsis_user_request = FactoryGirl.create(:nacsis_user_request, :user => other_user)
        get :show, {:id => nacsis_user_request.to_param}
        response.should be_forbidden
      end
    end
  end

  shared_examples '必須パラメータの指定がなければエラー画面を表示する' do
    def do_test_request(request_params, result = nil)
      result ||= {record_type => [nacsis_cat]}
      if result.is_a?(Exception)
        NacsisCat.stub(:search).and_raise(result)
      else
        NacsisCat.stub(:search).and_return(result)
      end

      if action == :new
        p = request_params
      else
        p = {:nacsis_user_request => request_params}
      end
      __send__(request_method, action, p)
      response.should be_forbidden
    end

    it 'request_typeパラメータの指定がなければエラー応答すること' do
      do_test_request({'ncid' => ncid, 'manifestation_type' => record_type.to_s})
    end

    it 'request_typeパラメータの値が不正のときエラー応答すること' do
      do_test_request({'request_type' => '-1', 'ncid' => ncid, 'manifestation_type' => record_type.to_s})
    end

    it 'ncidパラメータの指定がなければエラー応答すること' do
      do_test_request({'request_type' => '1', 'manifestation_type' => record_type.to_s})
    end

    it 'ncidパラメータの値が不正のときエラー応答すること' do
      result = {record_type => NacsisCat::ResultArray.new(nil)} # IDによるNACSIS-CAT検索で結果が得られなかった(在存しないIDだった)
      do_test_request({'request_type' => '1', 'ncid' => 'XXX', 'manifestation_type' => record_type.to_s}, result)
    end

    it 'manifestation_typeパラメータの指定がなければエラー応答すること' do
      do_test_request({'request_type' => '1', 'ncid' => ncid})
    end

    it 'manifestation_typeパラメータの値が不正のときエラー応答すること' do
      result = ArgumentError.new('invalid manifestation_type value')
      do_test_request({'request_type' => '1', 'ncid' => ncid, 'manifestation_type' => 'unknown'}, result)
    end
  end

  describe '#newは' do
    let(:request_method) { :get }
    let(:action) { :new }

    let(:valid_attributes) { {
      'request_type' => '1',
      'ncid' => ncid,
      'manifestation_type' => record_type.to_s,
    } }

    it 'NacsisUserRequestオブジェクトを@nacsis_user_requestに設定すること' do
      NacsisCat.stub(:search).and_return(record_type => [nacsis_cat])

      get :new, valid_attributes
      expect(assigns(:nacsis_user_request)).to be_a_new(NacsisUserRequest)
    end

    it 'ログイン中のユーザを@nacsis_user_request.userに設定すること' do
      NacsisCat.stub(:search).and_return(record_type => [nacsis_cat])

      get :new, valid_attributes
      expect(assigns(:nacsis_user_request).user).to eq(login_user)
    end

    it '指定されたレコード種別を@manifestation_typeに設定すること' do
      NacsisCat.stub(:search).and_return(record_type => [nacsis_cat])

      get :new, valid_attributes
      expect(assigns(:manifestation_type)).to eq(record_type.to_s)
    end

    it '一般書誌のレコードIDが与えられたとき、その書誌をもとにNacsisUserRequestオブジェクトを生成すること' do
      attrs = nacsis_cat.request_summary
      NacsisCat.should_receive(:search).with(:id => ncid, :dbs => [record_type]).and_return(record_type => [nacsis_cat])
      NacsisCat.any_instance.should_receive(:request_summary).and_return(attrs)

      get :new, valid_attributes
      nacsis_user_request = assigns(:nacsis_user_request)

      expect(nacsis_user_request.request_type).to eq(1)
      attrs.each_pair do |name, value|
        expect(nacsis_user_request.__send__(name)).to eq(attrs[name])
      end
    end

    it '雑誌書誌のレコードIDが与えられたとき、その書誌をもとにNacsisUserRequestオブジェクトを生成すること' do
      record_type = :serial
      nacsis_cat = nacsis_cat_with_mock_record(record_type)
      attrs = nacsis_cat.request_summary
      NacsisCat.should_receive(:search).with(:id => nacsis_cat.ncid, :dbs => [record_type]).and_return(record_type => [nacsis_cat])
      NacsisCat.any_instance.should_receive(:request_summary).and_return(attrs)

      get :new, valid_attributes.merge({
        'ncid' => nacsis_cat.ncid,
        'manifestation_type' => record_type.to_s,
      })
      nacsis_user_request = assigns(:nacsis_user_request)

      expect(nacsis_user_request.request_type).to eq(1)
      attrs.each_pair do |name, value|
        expect(nacsis_user_request.__send__(name)).to eq(attrs[name])
      end
    end

    include_examples '必須パラメータの指定がなければエラー画面を表示する'
  end

  describe '#editは' do
    it 'idパラメータで指定されたレコードを@nacsis_user_requestにロードすること' do
      nacsis_user_request = FactoryGirl.create(:nacsis_user_request)
      get :edit, {:id => nacsis_user_request.to_param}
      expect(assigns(:nacsis_user_request)).to eq(nacsis_user_request)
    end

    describe '一般ユーザでログインしているとき' do
      include_context '一般ユーザでログインする'

      it '他人のNacsisCatレコードにアクセスさせないこと' do
        nacsis_user_request = FactoryGirl.create(:nacsis_user_request, :user => other_user)
        get :edit, {:id => nacsis_user_request.to_param}
        response.should be_forbidden
      end
    end
  end

  describe '#createは' do
    let(:request_method) { :post }
    let(:action) { :create }

    let(:valid_attributes) { {
      'request_type' => '1',
      'ncid' => ncid,
      'manifestation_type' => record_type.to_s,
      'user_note' => 'user note',
    } }

    describe '正しいパラメータにより' do
      before do
        NacsisCat.should_receive(:search).with(:id => ncid, :dbs => [record_type]).and_return(record_type => [nacsis_cat])
      end

      it '新しいNacsisUserRequestレコードを作成すること' do
        expect {
          post :create, {:nacsis_user_request => valid_attributes}
        }.to change(NacsisUserRequest, :count).by(1)
      end

      it '新しく作成されたNacsisUserRequestレコードを@nacsis_user_requestにロードすること' do
        post :create, {:nacsis_user_request => valid_attributes}
        assigns(:nacsis_user_request).should be_a(NacsisUserRequest)
        assigns(:nacsis_user_request).should be_persisted
      end

      it '新しく作成されたNacsisUserRequestレコード参照画面にリダイレクトすること' do
        post :create, {:nacsis_user_request => valid_attributes}
        response.should redirect_to(NacsisUserRequest.last)
      end

      it 'librarian_noteに値を設定できること' do
        post :create, {
          :nacsis_user_request => valid_attributes.merge({
            :librarian_note => 'librarian note'
          })
        }
        assigns(:nacsis_user_request).librarian_note.should eq('librarian note')
      end

      it '指定されたレコード種別を@manifestation_typeに設定すること' do
        NacsisCat.stub(:search).and_return(record_type => [nacsis_cat])

        post :create, {:nacsis_user_request => valid_attributes}
        expect(assigns(:manifestation_type)).to eq(record_type.to_s)
      end
    end

    describe '一般ユーザでログインしているとき' do
      include_context '一般ユーザでログインする'

      before do
        NacsisCat.should_receive(:search).with(:id => ncid, :dbs => [record_type]).and_return(record_type => [nacsis_cat])
      end

      it 'librarian_noteに値を設定しないこと' do
        post :create, {
          :nacsis_user_request => valid_attributes.merge({
            :librarian_note => 'librarian note'
          })
        }
        response.should redirect_to(NacsisUserRequest.last)
        assigns(:nacsis_user_request).librarian_note.should be_blank
      end
    end

    include_examples '必須パラメータの指定がなければエラー画面を表示する'
  end

  describe '#updateは' do
    before do
      NacsisCat.should_not_receive(:search) # 更新時にはNACSIS-CATによる検索は行われない
    end

    describe '正しいパラメータにより' do
      it '指定されたNacsisUserRequestレコードを更新すること' do
        nacsis_user_request = FactoryGirl.create(:nacsis_user_request, :user_note => '')

        expect {
          put :update, {
            :id => nacsis_user_request.to_param,
            :nacsis_user_request => { 'user_note' => 'new note' },
          }
        }.to change {
          NacsisUserRequest.find(nacsis_user_request.id).user_note
        }.from('').to('new note')
      end

      it '更新後のレコードを@nacsis_user_requestにロードすること' do
        nacsis_user_request = FactoryGirl.create(:nacsis_user_request)
        put :update, {
          :id => nacsis_user_request.to_param,
          :nacsis_user_request => { 'user_note' => 'new note' },
        }
        assigns(:nacsis_user_request).should eq(nacsis_user_request)
      end

      it '新しく作成されたNacsisUserRequestレコード参照画面にリダイレクトすること' do
        nacsis_user_request = FactoryGirl.create(:nacsis_user_request)
        put :update, {
          :id => nacsis_user_request.to_param,
          :nacsis_user_request => { 'user_note' => 'new note' },
        }
        response.should redirect_to(nacsis_user_request)
      end

      it 'librarian_noteの値を変更できること' do
        nacsis_user_request = FactoryGirl.create(:nacsis_user_request, :librarian_note => '')

        expect {
          put :update, {
            :id => nacsis_user_request.to_param,
            :nacsis_user_request => { 'librarian_note' => 'new note' },
          }
        }.to change {
          NacsisUserRequest.find(nacsis_user_request.id).librarian_note
        }.from('').to('new note')
      end
    end

    describe '一般ユーザでログインしているとき' do
      include_context '一般ユーザでログインする'

      it '他人のNacsisUserRequestレコードを更新しないこと' do
        nacsis_user_request = FactoryGirl.create(:nacsis_user_request, :user => other_user)
        expect {
          put :update, {
            :id => nacsis_user_request.to_param,
            :nacsis_user_request => {
              'user_note' => 'new note',
            },
          }
          response.should be_forbidden
        }.not_to change {
          NacsisUserRequest.find(nacsis_user_request.id).user_note
        }
      end

      it 'librarian_noteの値を変更しないこと' do
        nacsis_user_request = FactoryGirl.create(:nacsis_user_request, :user => login_user)

        expect {
          put :update, {
            :id => nacsis_user_request.to_param,
            :nacsis_user_request => { 'librarian_note' => 'new note' },
          }
          response.should redirect_to(nacsis_user_request)
        }.not_to change {
          NacsisUserRequest.find(nacsis_user_request.id).librarian_note
        }
      end
    end
  end

  describe '#destroyは' do
    before do
      NacsisCat.should_not_receive(:search) # 更新時にはNACSIS-CATによる検索は行われない
    end

    it '指定されたNacsisUserRequestレコードを削除すること' do
      nacsis_user_request = FactoryGirl.create(:nacsis_user_request)
      expect {
        delete :destroy, {:id => nacsis_user_request.to_param}
      }.to change(NacsisUserRequest, :count).by(-1)
    end

    it '一覧ページにリダイレクトすること' do
      nacsis_user_request = FactoryGirl.create(:nacsis_user_request)
      delete :destroy, {:id => nacsis_user_request.to_param}
      response.should redirect_to(nacsis_user_requests_url)
    end

    describe '一般ユーザでログインしているとき' do
      include_context '一般ユーザでログインする'

      it '他人のNacsisUserRequestレコードを削除しないこと' do
        nacsis_user_request = FactoryGirl.create(:nacsis_user_request, :user => other_user)
        expect {
          delete :destroy, {:id => nacsis_user_request.to_param}
          response.should be_forbidden
        }.not_to change(NacsisUserRequest, :count)
      end
    end
  end

end
