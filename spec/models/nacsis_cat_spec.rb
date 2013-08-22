# encoding: utf-8
require 'spec_helper'

describe NacsisCat do
  include NacsisCatSpecHelper

  fixtures :countries

  describe '.newは' do
    it 'NACSIS書誌レコードを指定してオブジェクトを生成できること' do
      ncr = Object.new
      nc = NacsisCat.new(:record => ncr)
      expect(nc).to be_a(NacsisCat)
      expect(nc.record).to equal(ncr)
    end
  end

  describe '.searchは' do
    it '指定されたNACSIS書誌IDでNACSIS-CAT検索を行うこと' do
      nacsis_id = 'BA44908740'
      set_nacsis_cat_gw_client_stub({
        :has_errors? => false,
        :result_count => 1,
        :result_records => [nacsis_record_object],
      })

      records = NacsisCat.search(:id => nacsis_id)

      expect(records).to be_a(Array)
      expect(records.first).to be_a(NacsisCat)
    end

    describe '検索条件が空のとき' do
      it '実際の検索を行わないこと' do
        NacsisCat.should_not_receive(:request_gateway_to)
        records = NacsisCat.search(:db => :book)
        records = NacsisCat.search({})
        records = NacsisCat.search()
      end

      it '空の検索結果を返すこと' do
        records = NacsisCat.search(:db => :book)
        expect(records).to be_blank
      end
    end

    describe '検索条件が否定のみのとき' do
      it '実際の検索を行わないこと' do
        NacsisCat.should_not_receive(:request_gateway_to)
        records = NacsisCat.search(:except => {:query => ['foo']})
      end

      it '空の検索結果を返すこと' do
        records = NacsisCat.search(:except => {:query => ['foo']})
        expect(records).to be_blank
      end
    end

    it 'totalに応答する配列を返すこと' do
      nacsis_id = 'BA44908740'

      set_nacsis_cat_gw_client_stub({
        :has_errors? => false,
        :result_count => 1,
        :result_records => [nacsis_record_object],
      })

      records = NacsisCat.search(:id => nacsis_id)
      expect(records.total).to eq(1)
    end

    it 'raw_resultで生の検索結果を参照できる配列を返すこと' do
      nacsis_id = 'BA44908740'

      spec = {
        :has_errors? => false,
        :result_count => 1,
        :result_records => [nacsis_record_object],
      }
      set_nacsis_cat_gw_client_stub(spec)

      records = NacsisCat.search(:id => nacsis_id)
      spec.each_pair do |name, value|
        expect(records.raw_result.__send__(name)).to eq(value)
      end
    end

    describe ':dbオプションが' do
      before do
        set_nacsis_cat_gw_client_stub({
          :has_errors? => false,
          :result_count => 1,
          :result_records => [nacsis_record_object],
        })
        @cgc = EnjuNacsisCatp::CatGatewayClient.new
        EnjuNacsisCatp::CatGatewayClient.should_receive(:new).and_return(@cgc)
      end

=begin
      describe ':allのとき' do
        let(:db) { all }

        it 'BOOKとSERIALを対象にして検索を実行すること' do
# NOTE:
# CATPプロトコル上はBOOK:SERIALの横断的検索が可能だと思われる。
# 実際、BOOK:SERIALでの検索を行うと両種類のレコードを含んだ応答がある。
# しかしながらenju_nacsis_gatewayはこのような応答に対応しておらず
# 結果的に横断的検索は行えない。
          NacsisCat.search(:db => db, :id => 'foo')
          @cgc.container.db_type.should eq('BOOK')
          @cgc.container.db_names.should eq(%w(BOOK SERIAL))
        end

        it ':idパラメータで指定された値からID条件で検索を行うこと' do
          NacsisCat.search(:db => db, :id => 'foo')
          @cgc.container.query.should match(/\bID="/)
        end
      end
=end

      describe ':bookのとき' do
        let(:db) { :book }

        it 'BOOKを対象にして検索を実行すること' do
          NacsisCat.search(:db => db, :id => 'foo')
          @cgc.container.db_type.should eq('BOOK')
          @cgc.container.db_names.should eq(%w(BOOK))
        end

        it ':idパラメータで指定された値からID条件で検索を行うこと' do
          NacsisCat.search(:db => db, :id => 'foo')
          @cgc.container.query.should match(/\bID="/)
        end
      end

      describe ':serialのとき' do
        let(:db) { :serial }

        it 'SERIALを対象にして検索を実行すること' do
          NacsisCat.search(:db => db, :id => 'foo')
          @cgc.container.db_type.should eq('SERIAL')
          @cgc.container.db_names.should eq(%w(SERIAL))
        end

        it ':idパラメータで指定された値からID条件で検索を行うこと' do
          NacsisCat.search(:db => db, :id => 'foo')
          @cgc.container.query.should match(/\bID="/)
        end
      end

      describe ':bholdのとき' do
        let(:db) { :bhold }

        it 'BHOLDを対象にして検索を実行すること' do
          NacsisCat.search(:db => db, :id => 'foo')
          @cgc.container.db_type.should eq('BHOLD')
          @cgc.container.db_names.should eq(%w(BHOLD))
        end

        it ':idパラメータで指定された値からBID条件で検索を行うこと' do
          NacsisCat.search(:db => db, :id => 'foo')
          @cgc.container.query.should match(/\bBID="/)
        end
      end

      describe ':sholdのとき' do
        let(:db) { :shold }

        it 'SHOLDを対象にして検索を実行すること' do
          NacsisCat.search(:db => db, :id => 'foo')
          @cgc.container.db_type.should eq('SHOLD')
          @cgc.container.db_names.should eq(%w(SHOLD))
        end

        it ':idパラメータで指定された値からBID条件で検索を行うこと' do
          NacsisCat.search(:db => db, :id => 'foo')
          @cgc.container.query.should match(/\bBID="/)
        end
      end
    end

    describe ':dbオプションが不正な値のとき' do
      let(:db) { :unknown }

      it 'ArgumentError例外を発生させること' do
        expect {
          NacsisCat.search(:db => db, :id => 'foo')
        }.to raise_exception(ArgumentError)
      end
    end

    describe ':per_pageオプションが' do
      before do
        set_nacsis_cat_gw_client_stub({
          :has_errors? => false,
          :result_count => 1,
          :result_records => [nacsis_record_object],
        })
        @cgc = EnjuNacsisCatp::CatGatewayClient.new
        EnjuNacsisCatp::CatGatewayClient.should_receive(:new).and_return(@cgc)
      end

      it '与えられたとき拡張オプションを指定してリクエストを送信すること' do
        NacsisCat.search(:db => :book, :id => 'foo', :per_page => 5, :page => 1)
        @cgc.container.max_retrieve.should eq(5)
        opts = @cgc.container.extra_options
        opts.should be_present
        opts[:retrieve]['record_requested'].should eq(5)
      end
    end

    describe ':pageオプションが' do
      before do
        set_nacsis_cat_gw_client_stub({
          :has_errors? => false,
          :result_count => 1,
          :result_records => [nacsis_record_object],
        })
        @cgc = EnjuNacsisCatp::CatGatewayClient.new
        EnjuNacsisCatp::CatGatewayClient.should_receive(:new).and_return(@cgc)
      end

      it '1のときSEARCH_RETRIEVEリクエストを送信すること' do # FIXME?: もし可能ならSEARCHリクエスト一回で処理したい。Large-set-lower-boundの指定を外すことで可能になるかもしれないが未確認。
        NacsisCat.search(:db => :book, :id => 'foo', :per_page => 5, :page => 1)
        @cgc.container.command.should eq('SEARCH_RETRIEVE')
        opts = @cgc.container.extra_options
        opts.should be_present
        opts[:search]['large_lower_bound'].should eq(1)
        opts[:retrieve]['start_position'].should eq(1) # per_page*(page - 1) + 1
      end

      it '2のときSEARCH_RETRIEVEリクエストを送信すること' do
        NacsisCat.search(:db => :book, :id => 'foo', :per_page => 5, :page => 2)
        @cgc.container.command.should eq('SEARCH_RETRIEVE')
        opts = @cgc.container.extra_options
        opts.should be_present
        opts[:search]['large_lower_bound'].should eq(1)
        opts[:retrieve]['start_position'].should eq(6) # per_page*(page - 1) + 1
      end
    end
  end

  describe '.build_queryは' do
    def build_query(cond)
      NacsisCat.class_eval { build_query(cond) }
    end

    it ':query指定から_TITLE_、_AUTH_、PUBLKEY、SHKEYのOR条件の検索式を生成すること' do
      build_query(:query => %w(foo)).should eq('_TITLE_="foo" _AUTH_="foo" OR PUBLKEY="foo" OR SHKEY="foo" OR')
      build_query(:query => %w(foo bar)).should eq(
        '_TITLE_="foo" _AUTH_="foo" OR PUBLKEY="foo" OR SHKEY="foo" OR ' \
        '_TITLE_="bar" _AUTH_="bar" OR PUBLKEY="bar" OR SHKEY="bar" OR ' \
        'AND'
      )
    end

    it ':title指定から_TITLE_のAND条件の検索式を生成すること' do
      build_query(:title => %w(foo)).should eq('_TITLE_="foo"')
      build_query(:title => %w(foo bar)).should eq('_TITLE_="foo" _TITLE_="bar" AND')
    end

    it ':author指定から_AUTH_のAND条件の検索式を生成すること' do
      build_query(:author => %w(foo)).should eq('_AUTH_="foo"')
      build_query(:author => %w(foo bar)).should eq('_AUTH_="foo" _AUTH_="bar" AND')
    end

    it ':publisher指定からPUBLKEYのAND条件の検索式を生成すること' do
      build_query(:publisher => %w(foo)).should eq('PUBLKEY="foo"')
      build_query(:publisher => %w(foo bar)).should eq('PUBLKEY="foo" PUBLKEY="bar" AND')
    end

    it ':subject指定からSHKEYのAND条件の検索式を生成すること' do
      build_query(:subject => %w(foo)).should eq('SHKEY="foo"')
      build_query(:subject => %w(foo bar)).should eq('SHKEY="foo" SHKEY="bar" AND')
    end

    it ':id指定からIDの検索式を生成すること' do
      build_query(:id => 'foo').should eq('ID="foo"')
    end

    it ':bid指定からBIDの検索式を生成すること' do
      build_query(:bid => 'foo').should eq('BID="foo"')
    end

    it ':isbn指定からISBNKEYの検索式を生成すること' do
      build_query(:isbn => 'foo').should eq('ISBNKEY="foo"')
    end

    it ':issn指定からISSNKEYの検索式を生成すること' do
      build_query(:issn => 'foo').should eq('ISSNKEY="foo"')
    end

    it '複数の指定からAND条件の検索式を生成すること' do
      build_query(
        :title => %w(foo),
        :author => %w(bar)
      ).should eq('_TITLE_="foo" _AUTH_="bar" AND')

      build_query(
        :title => %w(foo),
        :author => %w(bar),
        :publisher => %w(baz)
      ).should eq('_TITLE_="foo" _AUTH_="bar" AND PUBLKEY="baz" AND')
    end

    it '否定の指定からAND-NOT条件の検索式を生成すること' do
      build_query(
        :title => %w(foo),
        :except => {:title => %w(bar)}
      ).should eq('_TITLE_="foo" _TITLE_="bar" AND-NOT')

      build_query(
        :title => %w(foo),
        :except => {:title => %w(bar baz)}
      ).should eq('_TITLE_="foo" _TITLE_="bar" _TITLE_="baz" OR AND-NOT')

      build_query(
        :title => %w(foo bar),
        :except => {:title => %w(baz quux)}
      ).should eq('_TITLE_="foo" _TITLE_="bar" AND _TITLE_="baz" _TITLE_="quux" OR AND-NOT')

      build_query(
        :title => %w(foo bar),
        :except => {:author => %w(baz), :publisher => %w(quux)}
      ).should eq('_TITLE_="foo" _TITLE_="bar" AND _AUTH_="baz" PUBLKEY="quux" OR AND-NOT')
    end
  end

  describe '.request_gateway_toは' do
    it '指定されたコマンドをゲートウェイに送信すること' do
      # ゲートウェイを経由してNACSIS-CATコマンドが実行されることを確認する
      cc0 = EnjuNacsisCatp::CatContainer.new
      EnjuNacsisCatp::CatGatewayClient.any_instance.should_receive(:execute).and_return(cc0)

      # CatContainerが内部で生成されるのを、テストのためにエミュレートしておく
      cc = EnjuNacsisCatp::CatContainer.new
      EnjuNacsisCatp::CatContainer.should_receive(:new) do |opts|
        opts.each_pair {|k, v| cc.__send__("#{k}=", v) } if opts
        cc
      end

      nacsis_id = 'BA44908740'
      NacsisCat.class_eval { request_gateway_to(:search, :query => %Q{ID="#{nacsis_id}"}, :db => :book) }

      # NACSIS-CATコマンドの内容が正しいことを確認する
      expect(cc.command).to be_present
      expect(cc.command).to eq('SEARCH')
      expect(cc.query).to be_present
      expect(cc.query).to match(/\bID="#{nacsis_id}"/)
    end

    it '応答レコード数に応じたNacsisCatオブジェクトを返すこと' do
      EnjuNacsisCatp::CatGatewayClient.any_instance.stub(:execute) do
        EnjuNacsisCatp::CatContainer.new(
          :result_records => [Object.new])
      end

      nacsis_id = 'BA44908740'
      result = NacsisCat.class_eval { request_gateway_to(:search, :query => %Q{ID="#{nacsis_id}"}, :db => :book) }

      expect(result).to be_a(Array)
      expect(result).to have(1).item
    end

    it 'ゲートウェイからの応答がエラーを示していたら例外を起こすこと' do
      # catp_codeが200以外、catp_errorsが空でない
      cc = EnjuNacsisCatp::CatContainer.new
      cc.result_records = []
      EnjuNacsisCatp::CatGatewayClient.any_instance.stub(:execute).and_return(cc)

      cc.catp_code = nil
      cc.catp_errors = %w(foo bar)
      expect {
        NacsisCat.search(:id => 'id')
      }.to raise_error(NacsisCat::UnknownError, /foo bar/)

      cc.catp_code = '400'
      cc.catp_errors = %w(foo bar)
      expect {
        NacsisCat.search(:id => 'id')
      }.to raise_error(NacsisCat::ClientError, /foo bar/)

      cc.catp_code = '500'
      cc.catp_errors = %w(foo bar)
      expect {
        NacsisCat.search(:id => 'id')
      }.to raise_error(NacsisCat::ServerError, /foo bar/)

      cc.catp_code = '200'
      cc.catp_errors = %w(foo bar)
      expect {
        NacsisCat.search(:id => 'id')
      }.to raise_error(NacsisCat::UnknownError, /foo bar/)

      cc.catp_errors = []
      expect {
        NacsisCat.search(:id => 'id')
      }.not_to raise_error
    end
  end

  describe '#serial?は' do
    it '雑誌の書誌に対してtrueを返すこと' do
      obj = NacsisCat.new(:record => EnjuNacsisCatp::SerialInfo.new)
      expect(obj).to be_serial
      expect(obj).not_to be_book
    end

    it '図書の書誌に対してfalseを返すこと' do
      obj = NacsisCat.new(:record => EnjuNacsisCatp::BookInfo.new)
      expect(obj).not_to be_serial
      expect(obj).to be_book
    end
  end

  describe '#ncidは' do
    it '図書の書誌に対してNCIDを返すこと' do
      nacsis_cat = nacsis_cat_with_mock_record(:book)
      expect(nacsis_cat.ncid).to eq('XX00000001')
    end

    it '雑誌の書誌に対してNCIDを返すこと' do
      nacsis_cat = nacsis_cat_with_mock_record(:serial)
      expect(nacsis_cat.ncid).to eq('XX00000001')
    end
  end

  describe '#isbnは' do
    it '図書の書誌に対して、ISBN情報を集めた配列を返すこと' do
      nacsis_cat = nacsis_cat_with_mock_record(:book)
      expect(nacsis_cat.isbn).to eq(['9780000000019', '9780000000026'])
    end

    it '雑誌の書誌に対して、nilを返すこと' do
      nacsis_cat = nacsis_cat_with_mock_record(:serial)
      expect(nacsis_cat.isbn).to be_nil
    end
  end

  describe '#issnは' do
    it '雑誌の書誌に対して、ISSN情報を返すこと' do
      nacsis_cat = nacsis_cat_with_mock_record(:serial)
      expect(nacsis_cat.issn).to eq('9780000000019')
    end

    it '図書の書誌に対して、nilを返すこと' do
      nacsis_cat = nacsis_cat_with_mock_record(:book)
      expect(nacsis_cat.issn).to be_nil
    end
  end

  describe '#summaryは' do
    it '図書の書誌に対して、一覧表示用の情報を集めたハッシュを返すこと' do
      nacsis_cat = nacsis_cat_with_mock_record(:book)
      expect(nacsis_cat.summary).to eq({
        :subject_heading => '本標題:標題関連情報/責任表示',
        :publisher => [['出版者1', '2013.6'], ['出版者2', '2013.7']],
        :series_title => [['親書誌1標題', '123'], ['親書誌2標題', nil]],
      })
    end

    it '雑誌の書誌に対して、一覧表示用の情報を集めたハッシュを返すこと' do
      nacsis_cat = nacsis_cat_with_mock_record(:serial)
      expect(nacsis_cat.summary).to eq({
        :subject_heading => '本標題:標題関連情報/責任表示',
        :publisher => [['出版者1', '2013.6'], ['出版者2', '2013.7']],
        :display_number => ['1集', 'Vol.1'],
      })
    end

    it '所蔵情報に対して、一覧表示用の情報を集めたハッシュを返すこと' do
      obj = Object.new
      obj.stub(:dbname => 'BHOLD')
      obj.stub(:hold_id => 'CD0000000001')
      obj.stub(:libabl => 'libabl')
      obj.stub(:holds => [
        Object.new.tap {|o| o.stub(:cln => 'cln1'); o.stub(:rgtn => 'rgtn1') },
        Object.new.tap {|o| o.stub(:cln => 'cln2'); o.stub(:rgtn => 'rgtn2') },
      ])

      nacsis_cat = NacsisCat.new(:record => obj)
      nacsis_cat.stub(:item? => true)

      expect(nacsis_cat.summary).to eq({
        :database => 'BHOLD',
        :hold_id => 'CD0000000001',
        :library_abbrev => 'libabl',
        :cln => 'cln1 cln2',
        :rgtn => 'rgtn1 rgtn2',
      })

      nacsis_cat.record.holds.pop

      expect(nacsis_cat.summary).to eq({
        :database => 'BHOLD',
        :hold_id => 'CD0000000001',
        :library_abbrev => 'libabl',
        :cln => 'cln1',
        :rgtn => 'rgtn1',
      })
    end
  end

  describe '#detailは' do
    it '図書の書誌に対して、詳細表示用の情報を集めたハッシュを返すこと' do
      nacsis_cat = nacsis_cat_with_mock_record(:book)
      expect(nacsis_cat.detail).to eq({
        :subject_heading => '本標題:標題関連情報/責任表示',
        :subject_heading_reading => 'ホンヒョウダイ ヨミ',
        :publisher => ['出版地a,出版者1,2013.6', '出版地b,出版者2,2013.7'],
        :publish_year => '2012',
        :physical_description => '237p;ll.;23cm;CD-ROM',
        :isbn => ['9780000000019', '9780000000026'],
        :pub_country => 'ja', # :pub_country => Country.where(:alpha_2 => 'JP').first, # XXX: 国コード体系がCountryとは異なる: http://www.loc.gov/marc/countries/countries_code.html
        :title_language => Language.where(:iso_639_3 => 'jpn').first,
        :text_language => Language.where(:iso_639_3 => 'jpn').first,
        :classmark => '分類の種類1:分類a;分類の種類9:分類b',
        :author_heading => ['著者1標目形(チョシャ1 ヨミ)', '著者2標目形(チョシャ2 ヨミ)'],
        :subject => ['件名1', '件名2'],
      })
    end

    it '雑誌の書誌に対して、詳細表示用の情報を集めたハッシュを返すこと' do
      nacsis_cat = nacsis_cat_with_mock_record(:serial)
      expect(nacsis_cat.detail).to eq({
        :subject_heading => '本標題:標題関連情報/責任表示',
        :subject_heading_reading => 'ホンヒョウダイ ヨミ',
        :publisher => ['出版地a,出版者1,2013.6', '出版地b,出版者2,2013.7'],
        :publish_year => '2012',
        :physical_description => '237p;ll.;23cm;CD-ROM',
        :issn => '9780000000019',
        :pub_country => 'ja', # :pub_country => Country.where(:alpha_2 => 'JP').first, # XXX: 国コード体系がCountryとは異なる: http://www.loc.gov/marc/countries/countries_code.html
        :title_language => Language.where(:iso_639_3 => 'jpn').first,
        :text_language => Language.where(:iso_639_3 => 'jpn').first,
        :classmark => nil,
        :author_heading => ['著者1標目形(チョシャ1 ヨミ)', '著者2標目形(チョシャ2 ヨミ)'],
        :subject => ['件名1', '件名2'],
      })
    end

    it '刊行年を"YYYY"または"YYYY1-YYYY2"の形式に変換すること' do
      nacsis_cat = nacsis_cat_with_mock_record(:book)
      year = nacsis_cat.record.year

      year.stub(:year1 => '2012')
      year.stub(:year2 => '2013')
      expect(nacsis_cat.detail[:publish_year]).to eq('2012-2013')

      year.stub(:year1 => nil)
      year.stub(:year2 => '2013')
      expect(nacsis_cat.detail[:publish_year]).to eq('2013')

      year.stub(:year1 => '2012')
      year.stub(:year2 => nil)
      expect(nacsis_cat.detail[:publish_year]).to eq('2012')

      year.stub(:year1 => nil)
      year.stub(:year2 => nil)
      expect(nacsis_cat.detail[:publish_year]).to be_nil
    end

    it '著者情報を"著者名"または"著者名(読み方)"の形式に変換すること' do
      nacsis_cat = nacsis_cat_with_mock_record(:book)
      nacsis_cat.record.stub(:als => [Object.new])
      al = nacsis_cat.record.als.first

      al.stub(:ahdng => '著者名')
      al.stub(:ahdngr => nil)
      expect(nacsis_cat.detail[:author_heading]).to eq(['著者名'])

      al.stub(:ahdng => '著者名')
      al.stub(:ahdngr => '読み方')
      expect(nacsis_cat.detail[:author_heading]).to eq(['著者名(読み方)'])

      al.stub(:ahdng => nil)
      al.stub(:ahdngr => '読み方')
      expect(nacsis_cat.detail[:author_heading]).to eq(['読み方'])

      al.stub(:ahdng => nil)
      al.stub(:ahdngr => nil)
      expect(nacsis_cat.detail[:author_heading]).to eq([])
    end

  end

  describe '#request_summaryは' do
    it '図書の書誌に対して、NacsisUserRequest作成用の情報を集めたハッシュを返すこと' do
      nacsis_cat = nacsis_cat_with_mock_record(:book)
      expect(nacsis_cat.request_summary).to eq({
        :subject_heading => '本標題:標題関連情報/責任表示',
        :publisher => '出版地a,出版者1,2013.6 出版地b,出版者2,2013.7',
        :pub_date => '2012',
        :physical_description => '237p;ll.;23cm;CD-ROM',
        :series_title => '親書誌1標題 123,親書誌2標題',
        :isbn => '9780000000019,9780000000026',
        :pub_country => 'ja', # :pub_country => Country.where(:alpha_2 => 'JP').first, # XXX: 国コード体系がCountryとは異なる: http://www.loc.gov/marc/countries/countries_code.html
        :title_language => Language.where(:iso_639_3 => 'jpn').first,
        :text_language => Language.where(:iso_639_3 => 'jpn').first,
        :classmark => '分類の種類1:分類a;分類の種類9:分類b',
        :author_heading => '著者1標目形(チョシャ1 ヨミ),著者2標目形(チョシャ2 ヨミ)',
        :subject => '件名1,件名2',
        :ncid => 'XX00000001',
      })
    end

    it '雑誌の書誌に対して、NacsisUserRequest作成用の情報を集めたハッシュを返すこと' do
      nacsis_cat = nacsis_cat_with_mock_record(:serial)
      expect(nacsis_cat.request_summary).to eq({
        :subject_heading => '本標題:標題関連情報/責任表示',
        :publisher => '出版地a,出版者1,2013.6 出版地b,出版者2,2013.7',
        :pub_date => '2012',
        :physical_description => '237p;ll.;23cm;CD-ROM',
        :series_title => nil,
        :isbn => nil,
        :pub_country => 'ja', # :pub_country => Country.where(:alpha_2 => 'JP').first, # XXX: 国コード体系がCountryとは異なる: http://www.loc.gov/marc/countries/countries_code.html
        :title_language => Language.where(:iso_639_3 => 'jpn').first,
        :text_language => Language.where(:iso_639_3 => 'jpn').first,
        :classmark => nil,
        :author_heading => '著者1標目形(チョシャ1 ヨミ),著者2標目形(チョシャ2 ヨミ)',
        :subject => '件名1,件名2',
        :ncid => 'XX00000001',
      })
    end
  end
end
