# encoding: utf-8
require 'spec_helper'

describe NacsisCat do
  include NacsisCatSpecHelper

  fixtures :countries

  describe '.newは' do
    it 'NACSIS書誌レコードを指定してオブジェクトを生成できること' do
      ncr = Object.new
      nc = NacsisCat.new(record: ncr)
      expect(nc).to be_a(NacsisCat)
      expect(nc.record).to equal(ncr)
    end
  end

  describe '.searchは' do
    it 'NACSIS-CAT検索を行うこと' do
      nacsis_id = 'BA44908740'
      NacsisCat.should_receive(:http_get_value) do |url|
        expect(url).to match(/\A#{Regexp.quote(NACSIS_CLIENT_CONFIG[Rails.env]['gw_account']['gw_url'])}/)

        {
          'status' => 'success',
          'results' => {
            '_ALL_' => {'records' => [{}]},
          },
        }
      end
      return_value = NacsisCat.search(:id => nacsis_id)

      expect(return_value).to be_a(Hash)
      expect(return_value[:all]).to be_a(Array)
      expect(return_value[:all].first).to be_a(NacsisCat)
    end

    describe '検索条件が空のとき' do
      it '実際の検索を行わないこと' do
        NacsisCat.should_not_receive(:http_get_value)
        NacsisCat.search(dbs: [:book])
        NacsisCat.search({})
        NacsisCat.search()
      end

      it '空の検索結果を返すこと' do
        records = NacsisCat.search(dbs: [:book])
        expect(records[:book]).to be_blank
      end
    end

    describe '検索条件が否定のみのとき' do
      it '実際の検索を行わないこと' do
        NacsisCat.should_not_receive(:http_get_value)
        NacsisCat.search(except: {query: ['foo']}, dbs: [:book])
      end

      it '空の検索結果を返すこと' do
        records = NacsisCat.search(except: {query: ['foo']}, dbs: [:book])
        expect(records[:book]).to be_blank
      end
    end

    it 'totalに応答する配列を返すこと' do
      nacsis_id = 'BA44908740'
      NacsisCat.stub(:http_get_value) do |url|
        {
          'status' => 'success',
          'results' => {
            'BOOK' => {'total' => 0},
            'SERIAL' => {'total' => 1},
          },
        }
      end

      return_value = NacsisCat.search(id: nacsis_id, dbs: [:book,:serial])
      expect(return_value[:book].total).to eq(0)
      expect(return_value[:serial].total).to eq(1)
    end

    it 'raw_resultで生の検索結果を参照できる配列を返すこと' do
      nacsis_id = 'BA44908740'
      book_result = {'records' => [{'_DBNAME_' => 'BOOK'}]}
      serial_result = {'records' => [{'_DBNAME_' => 'SERIAL'}]}
      NacsisCat.stub(:http_get_value) do |url|
        {
          'status' => 'success',
          'results' => {
            'BOOK' => book_result,
            'SERIAL' => serial_result,
          },
        }
      end

      return_value = NacsisCat.search(id: nacsis_id, dbs: [:book, :serial])
      expect(return_value[:book].raw_result).to eq(book_result)
      expect(return_value[:serial].raw_result).to eq(serial_result)
    end

    describe ':dbsオプションが' do
      before do
        @return_value = {
          'status' => 'success',
          'results' => {},
        }
        NacsisCat.should_receive(:http_get_value) do |url|
          @return_value[:url] = url
          @return_value
        end
      end

      describe ':allのとき' do
        let(:dbs) { [:all] }

        it '_ALL_を対象にして検索を実行すること' do
          NacsisCat.search(dbs: dbs, id: 'foo')
          q = {:db => %w(_ALL_)}.to_query
          expect(@return_value[:url]).to include(q)
        end

        it ':idパラメータで指定された値からID条件で検索を行うこと' do
          NacsisCat.search(dbs: dbs, id: 'foo')
          q = {:query => %(ID=")}.to_query
          expect(@return_value[:url]).to include(q)
        end
      end

      describe ':bookのとき' do
        let(:dbs) { [:book] }

        it 'BOOKを対象にして検索を実行すること' do
          NacsisCat.search(dbs: dbs, id: 'foo')
          q = {:db => %w(BOOK)}.to_query
          expect(@return_value[:url]).to include(q)
        end

        it ':idパラメータで指定された値からID条件で検索を行うこと' do
          NacsisCat.search(dbs: dbs, id: 'foo')
          q = {:query => %(ID=")}.to_query
          expect(@return_value[:url]).to include(q)
        end
      end

      describe ':serialのとき' do
        let(:dbs) { [:serial] }

        it 'SERIALを対象にして検索を実行すること' do
          NacsisCat.search(dbs: dbs, id: 'foo')
          q = {:db => %w(SERIAL)}.to_query
          expect(@return_value[:url]).to include(q)
        end

        it ':idパラメータで指定された値からID条件で検索を行うこと' do
          NacsisCat.search(dbs: dbs, id: 'foo')
          q = {:query => %(ID=")}.to_query
          expect(@return_value[:url]).to include(q)
        end
      end

      describe '[:book,:serial]のとき' do
        let(:dbs) { [:book, :serial] }

        it 'SERIALを対象にして検索を実行すること' do
          NacsisCat.search(dbs: dbs, id: 'foo')
          q = {:db => %w(BOOK SERIAL)}.to_query
          expect(@return_value[:url]).to include(q)
        end

        it ':idパラメータで指定された値からID条件で検索を行うこと' do
          NacsisCat.search(dbs: dbs, id: 'foo')
          q = {:query => %(ID=")}.to_query
          expect(@return_value[:url]).to include(q)
        end
      end

      describe ':bholdのとき' do
        let(:dbs) { [:bhold] }

        it 'BHOLDを対象にして検索を実行すること' do
          NacsisCat.search(dbs: dbs, id: 'foo')
          q = {:db => %w(BHOLD)}.to_query
          expect(@return_value[:url]).to include(q)
        end

        it ':idパラメータで指定された値からBID条件で検索を行うこと' do
          NacsisCat.search(dbs: dbs, id: 'foo')
          q = {:query => %(BID=")}.to_query
          expect(@return_value[:url]).to include(q)
        end
      end

      describe ':sholdのとき' do
        let(:dbs) { [:shold] }

        it 'SHOLDを対象にして検索を実行すること' do
          NacsisCat.search(dbs: dbs, id: 'foo')
          q = {:db => %w(SHOLD)}.to_query
          expect(@return_value[:url]).to include(q)
        end

        it ':idパラメータで指定された値からBID条件で検索を行うこと' do
          NacsisCat.search(dbs: dbs, id: 'foo')
          q = {:query => %(BID=")}.to_query
          expect(@return_value[:url]).to include(q)
        end
      end

      describe '[:bhold,:shold]のとき' do
        let(:dbs) { [:bhold, :shold] }

        it 'SHOLDを対象にして検索を実行すること' do
          NacsisCat.search(dbs: dbs, id: 'foo')
          q = {:db => %w(BHOLD SHOLD)}.to_query
          expect(@return_value[:url]).to include(q)
        end

        it ':idパラメータで指定された値からBID条件で検索を行うこと' do
          NacsisCat.search(dbs: dbs, id: 'foo')
          q = {:query => %(BID=")}.to_query
          expect(@return_value[:url]).to include(q)
        end
      end
    end

    describe ':dbsオプションが不正な値のとき' do
      let(:dbs) { [:unknown] }

      it 'ArgumentError例外を発生させること' do
        expect {
          NacsisCat.search(dbs: dbs, id: 'foo')
        }.to raise_exception(ArgumentError)
      end
    end

    describe ':optsオプションが与えられたとき' do
      before do
        @return_value = {
          'status' => 'success',
          'results' => {},
        }
        NacsisCat.should_receive(:http_get_value) do |url|
          @return_value[:url] = url
          @return_value
        end
      end

      it 'それを指定して検索を実行すること' do
        opts = {
          :book => {page: 1, per_page: 2},
        }
        expected_opts = {
          'BOOK' => {page: 1, per_page: 2},
        }
        NacsisCat.search(dbs: [:book], opts: opts, query: 'foo')
        expect(@return_value[:url]).to include({opts: expected_opts}.to_query)
      end

      it ':dbsオプションにないDBへのオプションを除いて検索を実行すること' do
        opts = {
          :book => {page: 1, per_page: 2},
          :serial => {page: 3, per_page: 4},
        }
        expected_opts = {
          'BOOK' => {page: 1, per_page: 2},
        }
        NacsisCat.search(dbs: [:book], opts: opts, query: 'foo')
        expect(@return_value[:url]).to include({opts: expected_opts}.to_query)
      end
    end
  end

  describe '.build_queryは' do
    def build_query(cond)
      NacsisCat.class_eval { build_query(cond) }
    end

    it ':query指定から_TITLE_、_AUTH_、PUBLKEY、SHKEYのOR条件の検索式を生成すること' do
      build_query(query: %w(foo)).should eq('_TITLE_="foo" _AUTH_="foo" OR PUBLKEY="foo" OR SHKEY="foo" OR')
      build_query(query: %w(foo bar)).should eq(
        '_TITLE_="foo" _AUTH_="foo" OR PUBLKEY="foo" OR SHKEY="foo" OR ' \
        '_TITLE_="bar" _AUTH_="bar" OR PUBLKEY="bar" OR SHKEY="bar" OR ' \
        'AND'
      )
    end

    it ':title指定から_TITLE_のAND条件の検索式を生成すること' do
      build_query(title: %w(foo)).should eq('_TITLE_="foo"')
      build_query(title: %w(foo bar)).should eq('_TITLE_="foo" _TITLE_="bar" AND')
    end

    it ':author指定から_AUTH_のAND条件の検索式を生成すること' do
      build_query(author: %w(foo)).should eq('_AUTH_="foo"')
      build_query(author: %w(foo bar)).should eq('_AUTH_="foo" _AUTH_="bar" AND')
    end

    it ':publisher指定からPUBLKEYのAND条件の検索式を生成すること' do
      build_query(publisher: %w(foo)).should eq('PUBLKEY="foo"')
      build_query(publisher: %w(foo bar)).should eq('PUBLKEY="foo" PUBLKEY="bar" AND')
    end

    it ':subject指定からSHKEYのAND条件の検索式を生成すること' do
      build_query(subject: %w(foo)).should eq('SHKEY="foo"')
      build_query(subject: %w(foo bar)).should eq('SHKEY="foo" SHKEY="bar" AND')
    end

    it ':id指定からIDの検索式を生成すること' do
      build_query(id: 'foo').should eq('ID="foo"')
    end

    it ':bid指定からBIDの検索式を生成すること' do
      build_query(bid: 'foo').should eq('BID="foo"')
    end

    it ':isbn指定からISBNKEYの検索式を生成すること' do
      build_query(isbn: 'foo').should eq('ISBNKEY="foo"')
    end

    it ':issn指定からISSNKEYの検索式を生成すること' do
      build_query(issn: 'foo').should eq('ISSNKEY="foo"')
    end

    it '複数の指定からAND条件の検索式を生成すること' do
      build_query(
        title: %w(foo),
        author: %w(bar)
      ).should eq('_TITLE_="foo" _AUTH_="bar" AND')

      build_query(
        title: %w(foo),
        author: %w(bar),
        publisher: %w(baz)
      ).should eq('_TITLE_="foo" _AUTH_="bar" AND PUBLKEY="baz" AND')
    end

    it '否定の指定からAND-NOT条件の検索式を生成すること' do
      build_query(
        title: %w(foo),
        except: {title: %w(bar)}
      ).should eq('_TITLE_="foo" _TITLE_="bar" AND-NOT')

      build_query(
        title: %w(foo),
        except: {title: %w(bar baz)}
      ).should eq('_TITLE_="foo" _TITLE_="bar" _TITLE_="baz" OR AND-NOT')

      build_query(
        title: %w(foo bar),
        except: {title: %w(baz quux)}
      ).should eq('_TITLE_="foo" _TITLE_="bar" AND _TITLE_="baz" _TITLE_="quux" OR AND-NOT')

      build_query(
        title: %w(foo bar),
        except: {author: %w(baz), publisher: %w(quux)}
      ).should eq('_TITLE_="foo" _TITLE_="bar" AND _AUTH_="baz" PUBLKEY="quux" OR AND-NOT')
    end
  end

  describe '.search_by_gatewayは' do
    it '指定された検索条件でゲートウェイにアクセスすること' do
      nacsis_id = 'BA44908740'

      NacsisCat.stub(:http_get_value) do |url|
        # NACSIS-CATサーバに正しい内容でアクセスしていることを確認する
        expect(url).to match(/\bquery=ID%3D%22#{nacsis_id}%22/) # query=ID="BA44908740"
        expect(url).to match(/\bdb%5B%5D=BOOK/) # DB[]=BOOK

        {
          'status' => 'success',
          'results' => {'BOOK' => {'records' => [{}]}},
        }
      end

      NacsisCat.class_eval { search_by_gateway(query: %Q{ID="#{nacsis_id}"}, dbs: [:book], opts: {}) }
    end

    it '応答レコード数に応じたNacsisCatオブジェクトを返すこと' do
      nacsis_id = 'BA44908740'
      NacsisCat.stub(:http_get_value) do |url|
        {
          'status' => 'success',
          'results' => {'BOOK' => {'records' => [{}]}},
        }
      end
      result = NacsisCat.class_eval { search_by_gateway(query: %Q{ID="#{nacsis_id}"}, dbs: [:book], opts: {}) }

      expect(result[:book]).to be_a(Array)
      expect(result[:book]).to have(1).item
    end

    it 'ゲートウェイからの応答がエラーを示していたら例外を起こすこと' do
      return_value = {}
      NacsisCat.stub(:http_get_value) do |url|
        return_value
      end

      return_value.replace(
        'status' => 'unknown',
        'phrase' => 'foo bar')
      expect {
        NacsisCat.search(id: 'id')
      }.to raise_error(NacsisCat::UnknownError, /foo bar/)

      return_value.replace(
        'status' => 'user-error',
        'phrase' => 'foo bar')
      expect {
        NacsisCat.search(id: 'id')
      }.to raise_error(NacsisCat::ClientError, /foo bar/)

      return_value.replace(
        'status' => 'gateway-error',
        'phrase' => 'foo bar')
      expect {
        NacsisCat.search(id: 'id')
      }.to raise_error(NacsisCat::ServerError, /foo bar/)

      return_value.replace(
        'status' => 'server-error',
        'phrase' => 'foo bar')
      expect {
        NacsisCat.search(id: 'id')
      }.to raise_error(NacsisCat::ServerError, /foo bar/)

      return_value.replace(
        'status' => 'success',
        'results' => {})
      expect {
        NacsisCat.search(id: 'id')
      }.not_to raise_error
    end

    it 'ゲートウェイにアクセスできなかったら例外を起こすこと' do
      ex = Errno::ECONNREFUSED.new
      NacsisCat.should_receive(:http_get_value) do |url|
        raise ex
      end

      expect {
        NacsisCat.search(id: 'id')
      }.to raise_error(NacsisCat::NetworkError, ex.message)
    end
  end

  describe '.http_get_valueは' do
    def http_get_value(url)
      NacsisCat.instance_eval { http_get_value(url) }
    end

    def http_response
      resp = Net::HTTPSuccess.new('1.1', '200', 'OK')
      resp.stub(:body => '{"status":"success"}')
      resp
    end

    let(:gateway_config) do
      NACSIS_CLIENT_CONFIG[Rails.env]['gw_account']
    end

    before do
      @__save__ = NACSIS_CLIENT_CONFIG[Rails.env]['gw_account'].dup
    end
    after do
      NACSIS_CLIENT_CONFIG[Rails.env]['gw_account'] = @__save__
    end

    let(:gateway_url) { 'http://localhost:12345/' }
    let(:gateway_uri) { URI(gateway_url) }

    it '引数のURLで指定されたホストにアクセスすること' do
      Net::HTTP.should_receive(:start) do |host, port, opts|
        expect(host).to eq(gateway_uri.host)
        expect(port).to eq(gateway_uri.port)
        http_response
      end
      http_get_value(gateway_url)
    end

    it '引数のURLがhttpのとき、use_ssl:falseでアクセスすること' do
      Net::HTTP.should_receive(:start) do |host, port, opts|
        expect(opts[:use_ssl]).to be_blank
        http_response
      end
      http_get_value(gateway_url)
    end

    describe '引数のURLがhttpsのとき' do
      let(:gateway_url) { 'https://localhost:12345/' }

      it 'use_ssl:trueでアクセスすること' do
        Net::HTTP.should_receive(:start) do |host, port, opts|
          expect(opts[:use_ssl]).to be_true
          http_response
        end
        http_get_value(gateway_url)
      end

      context 'nacsis_client.ymlでssl_verify:trueが指定されていたら' do
        before { gateway_config['ssl_verify'] = true }
        it 'verify_mode:OpenSSL::SSL::VERIFY_PEERでアクセスすること' do
          Net::HTTP.should_receive(:start) do |host, port, opts|
            expect(opts[:verify_mode]).to eq(OpenSSL::SSL::VERIFY_PEER)
            http_response
          end
          http_get_value(gateway_url)
        end
      end

      context 'nacsis_client.ymlでssl_verify:falseが指定されていたら' do
        before { gateway_config['ssl_verify'] = false }
        it 'verify_mode:OpenSSL::SSL::VERIFY_NONEでアクセスすること' do
          Net::HTTP.should_receive(:start) do |host, port, opts|
            expect(opts[:verify_mode]).to eq(OpenSSL::SSL::VERIFY_NONE)
            http_response
          end
          http_get_value(gateway_url)
        end
      end

      context 'nacsis_client.ymlでssl_verifyが指定されていなかったら' do
        before { gateway_config.delete('ssl_verify') }
        it 'verify_mode:OpenSSL::SSL::VERIFY_PEERでアクセスすること' do
          Net::HTTP.should_receive(:start) do |host, port, opts|
            expect(opts[:verify_mode]).to eq(OpenSSL::SSL::VERIFY_PEER)
            http_response
          end
          http_get_value(gateway_url)
        end
      end
    end
  end

  describe '#serial?は' do
    it '雑誌の書誌に対してtrueを返すこと' do
      obj = NacsisCat.new(record: nacsis_record_object(:serial))
      expect(obj).to be_serial
      expect(obj).not_to be_book
    end

    it '図書の書誌に対してfalseを返すこと' do
      obj = NacsisCat.new(record: nacsis_record_object(:book))
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
        subject_heading: '本標題:標題関連情報/責任表示',
        publisher: [['出版者1', '2013.6'], ['出版者2', '2013.7']],
        series_title: [['親書誌1標題', '123'], ['親書誌2標題', nil]],
      })
    end

    it '雑誌の書誌に対して、一覧表示用の情報を集めたハッシュを返すこと' do
      nacsis_cat = nacsis_cat_with_mock_record(:serial)
      expect(nacsis_cat.summary).to eq({
        subject_heading: '本標題:標題関連情報/責任表示',
        publisher: [['出版者1', '2013.6'], ['出版者2', '2013.7']],
        display_number: ['1集', 'Vol.1'],
      })
    end

    it '所蔵情報に対して、一覧表示用の情報を集めたハッシュを返すこと' do
      obj = {
        '_DBNAME_' => 'BHOLD',
        'ID' => 'CD0000000001',
        'LIBABL' => 'libabl',
        'HOLD' => [
          {'CLN' => 'cln1', 'RGTN' => 'rgtn1'},
          {'CLN' => 'cln2', 'RGTN' => 'rgtn2'},
        ],
      }

      nacsis_cat = NacsisCat.new(record: obj)
      nacsis_cat.stub(item?: true)

      expect(nacsis_cat.summary).to eq({
        database: 'BHOLD',
        hold_id: 'CD0000000001',
        library_abbrev: 'libabl',
        cln: 'cln1 cln2',
        rgtn: 'rgtn1 rgtn2',
      })

      nacsis_cat.record['HOLD'].pop

      expect(nacsis_cat.summary).to eq({
        database: 'BHOLD',
        hold_id: 'CD0000000001',
        library_abbrev: 'libabl',
        cln: 'cln1',
        rgtn: 'rgtn1',
      })
    end
  end

  describe '#detailは' do
    it '図書の書誌に対して、詳細表示用の情報を集めたハッシュを返すこと' do
      nacsis_cat = nacsis_cat_with_mock_record(:book)
      expect(nacsis_cat.detail).to eq({
        subject_heading: '本標題:標題関連情報/責任表示',
        subject_heading_reading: 'ホンヒョウダイ ヨミ',
        publisher: ['出版地a,出版者1,2013.6', '出版地b,出版者2,2013.7'],
        publish_year: '2012',
        physical_description: '237p;ll.;23cm;CD-ROM',
        isbn: ['9780000000019', '9780000000026'],
        pub_country: 'ja', # pub_country: Country.where(alpha_2: 'JP').first, # XXX: 国コード体系がCountryとは異なる: http://www.loc.gov/marc/countries/countries_code.html
        title_language: Language.where(iso_639_3: 'jpn').first,
        text_language: Language.where(iso_639_3: 'jpn').first,
        classmark: '分類の種類1:分類a;分類の種類9:分類b',
        author_heading: ['著者1標目形(チョシャ1 ヨミ)', '著者2標目形(チョシャ2 ヨミ)'],
        subject: ['件名1', '件名2'],
      })
    end

    it '雑誌の書誌に対して、詳細表示用の情報を集めたハッシュを返すこと' do
      nacsis_cat = nacsis_cat_with_mock_record(:serial)
      expect(nacsis_cat.detail).to eq({
        subject_heading: '本標題:標題関連情報/責任表示',
        subject_heading_reading: 'ホンヒョウダイ ヨミ',
        publisher: ['出版地a,出版者1,2013.6', '出版地b,出版者2,2013.7'],
        publish_year: '2012',
        physical_description: '237p;ll.;23cm;CD-ROM',
        issn: '9780000000019',
        pub_country: 'ja', # pub_country: Country.where(alpha_2: 'JP').first, # XXX: 国コード体系がCountryとは異なる: http://www.loc.gov/marc/countries/countries_code.html
        title_language: Language.where(iso_639_3: 'jpn').first,
        text_language: Language.where(iso_639_3: 'jpn').first,
        classmark: nil,
        author_heading: ['著者1標目形(チョシャ1 ヨミ)', '著者2標目形(チョシャ2 ヨミ)'],
        subject: ['件名1', '件名2'],
      })
    end

    it '刊行年を"YYYY"または"YYYY1-YYYY2"の形式に変換すること' do
      nacsis_cat = nacsis_cat_with_mock_record(:book)
      nacsis_cat = Marshal.load(Marshal.dump(nacsis_cat)) # deep copy
      year = nacsis_cat.record['YEAR']

      year.replace({'YEAR1' => '2012', 'YEAR2' => '2013'})
      expect(nacsis_cat.detail[:publish_year]).to eq('2012-2013')

      year.replace({'YEAR2' => '2013'})
      expect(nacsis_cat.detail[:publish_year]).to eq('2013')

      year.replace({'YEAR1' => '2012'})
      expect(nacsis_cat.detail[:publish_year]).to eq('2012')

      year.replace({})
      expect(nacsis_cat.detail[:publish_year]).to be_nil
    end

    it '著者情報を"著者名"または"著者名(読み方)"の形式に変換すること' do
      nacsis_cat = nacsis_cat_with_mock_record(:book)
      nacsis_cat = Marshal.load(Marshal.dump(nacsis_cat)) # deep copy
      al = {}
      nacsis_cat.record['AL'] = [al]

      al.replace({'AHDNG' => '著者名'})
      expect(nacsis_cat.detail[:author_heading]).to eq(['著者名'])

      al.replace({'AHDNG' => '著者名', 'AHDNGR' => '読み方'})
      expect(nacsis_cat.detail[:author_heading]).to eq(['著者名(読み方)'])

      al.replace({'AHDNGR' => '読み方'})
      expect(nacsis_cat.detail[:author_heading]).to eq(['読み方'])

      al.replace({})
      expect(nacsis_cat.detail[:author_heading]).to eq([])
    end

  end

  describe '#request_summaryは' do
    it '図書の書誌に対して、NacsisUserRequest作成用の情報を集めたハッシュを返すこと' do
      nacsis_cat = nacsis_cat_with_mock_record(:book)
      expect(nacsis_cat.request_summary).to eq({
        subject_heading: '本標題:標題関連情報/責任表示',
        publisher: '出版地a,出版者1,2013.6 出版地b,出版者2,2013.7',
        pub_date: '2012',
        physical_description: '237p;ll.;23cm;CD-ROM',
        series_title: '親書誌1標題 123,親書誌2標題',
        isbn: '9780000000019,9780000000026',
        pub_country: 'ja', # pub_country: Country.where(alpha_2: 'JP').first, # XXX: 国コード体系がCountryとは異なる: http://www.loc.gov/marc/countries/countries_code.html
        title_language: Language.where(iso_639_3: 'jpn').first,
        text_language: Language.where(iso_639_3: 'jpn').first,
        classmark: '分類の種類1:分類a;分類の種類9:分類b',
        author_heading: '著者1標目形(チョシャ1 ヨミ),著者2標目形(チョシャ2 ヨミ)',
        subject: '件名1,件名2',
        ncid: 'XX00000001',
      })
    end

    it '雑誌の書誌に対して、NacsisUserRequest作成用の情報を集めたハッシュを返すこと' do
      nacsis_cat = nacsis_cat_with_mock_record(:serial)
      expect(nacsis_cat.request_summary).to eq({
        subject_heading: '本標題:標題関連情報/責任表示',
        publisher: '出版地a,出版者1,2013.6 出版地b,出版者2,2013.7',
        pub_date: '2012',
        physical_description: '237p;ll.;23cm;CD-ROM',
        series_title: nil,
        isbn: nil,
        pub_country: 'ja', # pub_country: Country.where(alpha_2: 'JP').first, # XXX: 国コード体系がCountryとは異なる: http://www.loc.gov/marc/countries/countries_code.html
        title_language: Language.where(iso_639_3: 'jpn').first,
        text_language: Language.where(iso_639_3: 'jpn').first,
        classmark: nil,
        author_heading: '著者1標目形(チョシャ1 ヨミ),著者2標目形(チョシャ2 ヨミ)',
        subject: '件名1,件名2',
        ncid: 'XX00000001',
      })
    end
  end
end
