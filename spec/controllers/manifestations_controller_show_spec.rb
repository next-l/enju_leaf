# encoding: utf-8
require 'spec_helper'

describe ManifestationsController do
  fixtures :all

  describe '#showは', :solr => false do
    let(:user) { FactoryGirl.create(:user) }
    let(:admin) { FactoryGirl.create(:admin) }
    let(:librarian) { FactoryGirl.create(:librarian) }

    describe 'idパラメータで指定されたManifestationが検索対象でないとき' do
      before do
        Manifestation.any_instance.stub(:non_searchable? => true)
      end

      it '非ログインアクセスを拒否すること' do
        get :show, :id => 1
        response.should_not be_success
      end

      it '一般ユーザアクセスを拒否すること' do
        sign_in user
        get :show, :id => 1
        response.should be_forbidden
      end

      it '図書館員アクセスを許可すること' do
        sign_in librarian
        get :show, :id => 1
        response.should be_success
        assigns(:manifestation).should eq(Manifestation.find(1))
      end
    end
  end

  describe '#show_nacsisは', :solr => false do
    include NacsisCatSpecHelper

    let(:nacsis_cat) { nacsis_cat_with_mock_record(:book) }
    let(:ncid) { nacsis_cat.record.bibliog_id }

    let(:result_spec_0) { {
      :has_errors? => false,
      :result_count => 0,
      :result_records => [],
    } }
    let(:result_spec_1) { {
      :has_errors? => false,
      :result_count => 1,
      :result_records => [nacsis_cat.record],
    } }

    it 'ncidパラメータ値によってNACSIS-CAT検索を実行すること' do
      cgc = EnjuNacsisCatp::CatGatewayClient.new
      EnjuNacsisCatp::CatGatewayClient.stub(:new => cgc)
      set_nacsis_cat_gw_client_stub([result_spec_1, result_spec_0])

      get :show_nacsis, :ncid => ncid, :manifestation_type => 'book'
      response.should be_success
    end

    it '@manifestationにNacsisCatオブジェクトを設定すること' do
      nacsis_cat_i = Object.new
      nacsis_cat_i.stub(:summary => {})

      NacsisCat.should_receive(:search).
        with(:db => :book, :id => ncid).
        and_return([nacsis_cat])
      NacsisCat.should_receive(:search).
        with(:db => :bhold, :id => ncid).
        and_return([nacsis_cat_i])

      get :show_nacsis, :ncid => ncid, :manifestation_type => 'book'
      assigns(:items).should be_present
      assigns(:items).should have(1).item
    end

    it '@itemsに所蔵情報の配列を設定すること' do
    end

    it '存在しないIDが指定されたら404応答を返すこと' do
      set_nacsis_cat_gw_client_stub(result_spec_0)

      get :show_nacsis, :ncid => 'dummy', :manifestation_type => 'book'
      response.should be_not_found
      assigns(:nacsis_cat).should be_blank
    end

    describe 'manifestation_typeパラメータが' do
      it 'bookなら一般書誌検索を行うこと' do
        NacsisCat.should_receive(:search).
          with(:db => :book, :id => 'dummy').
          and_return(NacsisCat::ResultArray.new(nil))
        get :show_nacsis, :ncid => 'dummy', :manifestation_type => 'book'
      end

      it 'serialなら雑誌書誌検索を行うこと' do
        NacsisCat.should_receive(:search).
          with(:db => :serial, :id => 'dummy').
          and_return(NacsisCat::ResultArray.new(nil))
        get :show_nacsis, :ncid => 'dummy', :manifestation_type => 'serial'
      end

      it '不適切なら404応答を返すこと' do
        get :show_nacsis, :ncid => ncid, :manifestation_type => 'bad'
        response.should be_not_found
      end
    end
  end

end
