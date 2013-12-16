# encoding: utf-8
require 'spec_helper'

describe ManifestationsController do
  fixtures :all

  describe '#indexは', :solr => true do
    def set_nacsis_search_each(v)
      update_system_configuration('nacsis.search_each', v)
    end

    before do
      Rails.cache.clear # SystemConfiguration由来の値が不定になるのを避けるため
      set_nacsis_search_each(true) # このブロックではnacsis.search_each==trueを基本とする
    end

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

    describe 'indexパラメータがlocalのとき' do
      before do
        sign_in admin

        Rails.cache.clear
        s = SystemConfiguration.where(keyname: 'manifestations.split_by_type').first
        s.v = 'false'
        s.save!
      end

      after do
        Rails.cache.clear

        sign_out :user
      end

      describe '詳細検索パラメータの' do
        def it_should_search_with_advanced_params(params, expected_titles, extra_params = {per_page: '100'})
          direct_mode = params.delete(:direct_mode)

          query_params =
            params. # 主要なテスト対象パラメータ
            reverse_merge(extra_params) # テスト対象には関係ないが動作のために必要なパラメータ(エラー時に表示されない)
          get :index, query_params

          msg_head = "(#{params.map {|k, v| "#{k}=#{v}" }.join(' ')})"

          if direct_mode == true
            m = Manifestation.where(original_title: expected_titles.first).first
            l = manifestation_url(id: m.id)
            expect(response).to be_redirect,
              "#{msg_head} expected redirect? to return true, got false"
            expect(response).to redirect_to(l),
              "#{msg_head} expected #{l}, got #{response.location}"
            return
          end

          expect(response).to be_success,
            "#{msg_head} expected success? to return true, got false"

          manifestations = assigns(:manifestations)
          orig_titles = manifestations.map(&:original_title).sort
          expected_titles = expected_titles.sort

          if expected_titles.blank?
            expect(manifestations).to be_blank,
              "#{msg_head} expected no records, got some records (#{orig_titles.join(',')})"
            return
          end
          expect(manifestations).to be_present,
            "#{msg_head} expected some records, got no records"

          expect(manifestations).to have(expected_titles.size).items,
            "#{msg_head} expected #{expected_titles.size} records (#{expected_titles.join(',')}), got #{manifestations.size} records (#{orig_titles.join(',')})"

          expect(orig_titles).to eq(expected_titles),
            "#{msg_head} expected #{expected_titles.join(',')} records, got #{orig_titles.join(',')}"

          if block_given?
            yield(manifestations)
          end
        end

        before do
          Sunspot.remove_all!

          patrons = [
            ['青森県',             'あおもりけん'],           #0
              ['青森県弘前市',     'あおもりけんひろさきし'], #1
              ['青森県八戸市',     'あおもりけんはちのへし'], #2
                ['平川市青森県',   'ひらかわしあおもりけん'], #3
            ['岩手県',             'いわてけん'],             #4
              ['岩手県盛岡市',     'いわてけんもりおかし'],   #5
              ['岩手県宮古市',     'いわてけんみやこし'],     #6
                ['奥州市岩手県',   'おうしゅうしいわてけん'], #7
            ['宮城県',             'みやぎけん'],             #8
              ['宮城県仙台市',     'みやぎけんせんだいし'],   #9
              ['宮城県石巻市',     'みやぎけんいしのまきし'], #10
                ['大崎市宮城県',   'おおさきしみやぎけん'],   #11
            ['千葉県',             'ちばけん'],               #12
              ['千葉県 松戸市',    'ちばけん まつどし'],      #13
                ['松戸市 千葉県',  'まつどし ちばけん'],      #14
              ['千葉県　成田市',   'ちばけん　なりたし'],     #15
                ['成田市　千葉県', 'なりたし　ちばけん'],     #16
          ].map do |n, t|
            FactoryGirl.create(
              :patron, full_name: n, full_name_transcription: t)
          end

          [
            ['北海道',             'ほっかいどう',           patrons[0, 2]],
              ['北海道札幌市',     'ほっかいどうさっぽろし', patrons[2, 1]],
              ['北海道千歳市',     'ほっかいどうちとせし',   patrons[3, 1]],
                ['根室市北海道',   'ねむろしほっかいどう',   patrons[4, 2]],
            ['秋田県',             'あきたけん',             patrons[6, 3]],
              ['秋田県能代市',     'あきたけんのしろし',     patrons[9, 2]],
            ['群馬県',             'ぐんまけん',             patrons[12, 1]],
              ['群馬県 前橋市',    'ぐんまけん まえばしし',  patrons[13, 1]],
                ['前橋市 群馬県',  'まえばしし ぐんまけん',  patrons[14, 1]],
              ['群馬県　高崎市',   'ぐんまけん　たかさきし', patrons[15, 2]],
                ['高崎市　群馬県', 'たかさきし　ぐんまけん', patrons[16, 2]],
          ].each do |o, t, p|
            m = FactoryGirl.create(
              :manifestation,
              original_title: o,
              title_transcription: t,
              creators: p)
            FactoryGirl.create(:item, manifestation: m)
          end

          Sunspot.commit
        end

        describe 'query_mergeが' do
          describe '無指定のとき' do
            it '検索語のすべてにマッチするレコードを抽出すること' do
              get :index, query: '秋田県 岩手県', query_merge: nil
              expect(response).to be_success

              manifestations = assigns(:manifestations)
              expect(manifestations).to be_present
              expect(manifestations).to have(1).item
              expect(manifestations.first.original_title).to eq('秋田県')
            end
          end

          describe 'anyのとき' do
            it '検索語のどれかにマッチするレコードを抽出すること' do
              get :index, query: '秋田県 岩手県', query_merge: 'any'
              expect(response).to be_success

              manifestations = assigns(:manifestations)
              expect(manifestations).to be_present
              expect(manifestations).to have(3).item
              r = /\A(?:秋田県|秋田県能代市|根室市北海道)\z/
              expect(manifestations).to be_all do |m|
                r =~ m.original_title
              end
            end
          end

          describe 'startwithのとき' do
            it '前方一致するレコードを抽出すること' do
              # NOTE: 主要なインデックス項目のみテストしている
              [
                ['北海道', ['北海道', '北海道札幌市', '北海道千歳市']],
                ['岩手', ['根室市北海道', '秋田県']],
              ].each do |qword, expected_titles|
                it_should_search_with_advanced_params(
                  {query: qword, query_merge: 'startwith'},
                  expected_titles)
              end
            end

            it '前方一致するレコードを抽出すること(空白を含むケース)' do
              [
                # title_sm:
                ['群馬県 前橋市', ['群馬県 前橋市']],
                ['群馬県 前橋', ['群馬県 前橋市']],
                  ['群馬県　前橋市', []],
                ['群馬県　高崎市', ['群馬県　高崎市']],
                ['群馬県　高崎', ['群馬県　高崎市']],
                  ['群馬県 高崎市', []],
                # creator_sm(NOTE: creator_smには空白(0x20)が除かれてからインデックス登録される):
                ['千葉県松戸市', ['群馬県 前橋市']],
                  ['千葉県 松戸市', []],
                  ['千葉県　松戸市', []],
                ['千葉県　成田市', ['群馬県　高崎市']],
                  ['千葉県 成田市', []],
              ].each do |qword, expected_titles|
                it_should_search_with_advanced_params(
                  {query: qword, query_merge: 'startwith'},
                  expected_titles)
              end
            end
          end
        end

        describe 'except_queryが与えられたとき' do
          it '指定語を含まないレコードを抽出すること' do
            [nil, 'any', 'all', 'startwith'].each do |merge|
              get :index, query: '岩手県', except_query: '秋田', query_merge: merge
              expect(response).to be_success

              manifestations = assigns(:manifestations)
              expect(manifestations).to be_present,
                "[query_merge=#{merge.inspect}] expected @manifestations, got false"
              expect(manifestations).to have(1).item,
                "[query_merge=#{merge.inspect}] expected 1 item, got #{manifestations.size} items"
              expect(manifestations.first.original_title).to eq('根室市北海道'),
                "[query_merge=#{merge.inspect}] expected \"根室市北海道\" item, got #{manifestations.first.original_title.inspect}"
            end
          end
        end

        describe 'title_mergeが' do
          describe '無指定のとき' do
            it 'タイトルが検索語のすべてにマッチするレコードを抽出すること' do
              it_should_search_with_advanced_params(
                {title: '北海道 ちとせ', title_merge: nil},
                ['北海道千歳市'])
            end
          end

          describe 'anyのとき' do
            it 'タイトルが検索語のどれかにマッチするレコードを抽出すること' do
              it_should_search_with_advanced_params(
                {title: '北海道 のしろ', title_merge: 'any'},
                ['北海道', '北海道札幌市', '北海道千歳市', '根室市北海道', '秋田県能代市'])
            end
          end

          describe 'exactのとき' do
            it 'タイトルが完全一致するレコードを抽出すること' do
              it_should_search_with_advanced_params(
                {title: '北海道', title_merge: 'exact'},
                ['北海道'])
            end

            it 'タイトルが完全一致するレコードを抽出すること(空白を含むケース)' do
              [
                ['群馬県', ['群馬県']],
                ['群馬県 前橋市', ['群馬県 前橋市']],
                ['群馬県　前橋市', []],
                ['群馬県　高崎市', ['群馬県　高崎市']],
                ['群馬県 高崎市', []],
              ].each do |qword, expected_titles|
                it_should_search_with_advanced_params(
                  {title: qword, title_merge: 'exact'},
                  expected_titles)
              end
            end
          end

          describe 'startwithのとき' do
            it 'タイトルが前方一致するレコードを抽出すること' do
              it_should_search_with_advanced_params(
                {title: '北海道', title_merge: 'startwith'},
                ['北海道', '北海道札幌市', '北海道千歳市'])
            end

            it 'タイトルが前方一致するレコードを抽出すること(空白を含むケース)' do
              [
                ['群馬県', ['群馬県', '群馬県 前橋市', '群馬県　高崎市']],
                ['群馬県 前橋市', ['群馬県 前橋市']],
                ['群馬県 前橋', ['群馬県 前橋市']],
                ['群馬 前橋', []],
                ['群馬県　前橋市', []],
                ['群馬県　高崎市', ['群馬県　高崎市']],
                ['群馬県　高崎', ['群馬県　高崎市']],
                ['群馬　高崎', []],
                ['群馬県 高崎市', []],
              ].each do |qword, expected_titles|
                it_should_search_with_advanced_params(
                  {title: qword, title_merge: 'startwith'},
                  expected_titles)
              end
            end
          end
        end

        describe 'except_titleが与えられたとき' do
          it 'タイトルに指定語を含まないレコードを抽出すること' do
            it_should_search_with_advanced_params(
              {query: '青森県', except_title: '千歳 札幌 青森'},
              ['北海道'])
          end
        end

        describe 'creator_mergeが'do
          describe '無指定のとき' do
            it '著者が検索語のすべてにマッチするレコードを抽出すること' do
              it_should_search_with_advanced_params(
                {creator: '岩手県 みやこ', creator_merge: nil},
                ['秋田県']) do |manifestations|
                  ns = manifestations.first.creators.map do |c|
                    [c.full_name, c.full_name_transcription]
                  end.flatten
                  expect(ns).to be_any {|n| /岩手県/ =~ n }
                  expect(ns).to be_any {|n| /みやこ/ =~ n }
                end
            end
          end

          describe 'anyのとき' do
            it '著者が検索語のどれかにマッチするレコードを抽出すること' do
              it_should_search_with_advanced_params(
                {creator: '岩手県 はちのへ', creator_merge: 'any'},
                ['北海道札幌市', '根室市北海道', '秋田県']) do |manifestations|
                  manifestations.all? do |m|
                    ns = m.creators.map do |c|
                      [c.full_name, c.full_name_transcription]
                    end.flatten
                    expect(ns).to be_any {|n| /岩手県|はちのへ/ =~ n }
                  end
                end
            end
          end

          describe 'exactのとき' do
            it '著者が完全一致するレコードを抽出すること' do
              it_should_search_with_advanced_params(
                {creator: '青森県', creator_merge: 'exact'},
                ['北海道']) do |manifestations|
                  expect(manifestations.first.creators).to be_any {|c| c.full_name == '青森県' }
                end
            end

            it '著者が完全一致するレコードを抽出すること(空白を含むケース)' do
              [
                ['千葉県', ['群馬県']],
                ['千葉県 松戸市', ['群馬県 前橋市']],
                ['千葉県　松戸市', []],
                ['千葉県　成田市', ['群馬県　高崎市']],
                ['千葉県 成田市', []],
              ].each do |qword, expected_titles|
                it_should_search_with_advanced_params(
                  {creator: qword, creator_merge: 'exact'},
                  expected_titles)
              end
            end
          end

          describe 'startwithのとき' do
            it '著者が前方一致するレコードを抽出すること' do
              it_should_search_with_advanced_params(
                {creator: '青森県', creator_merge: 'startwith'},
                ['北海道', '北海道札幌市']) do |manifestations|
                  expect(manifestations).to be_all do |m|
                    m.creators.any? {|c| /\A青森県/ =~ c.full_name }
                  end
                end
            end

            it '著者が前方一致するレコードを抽出すること(空白を含むケース)' do
              [
                ['千葉県', ['群馬県', '群馬県 前橋市', '群馬県　高崎市']],
                ['千葉県 松戸', ['群馬県 前橋市']],
                ['千葉県　松戸', []],
                ['千葉 松戸', []],
                ['千葉県　成田', ['群馬県　高崎市']],
                ['千葉県 成田', []],
                ['千葉 成田', []],
              ].each do |qword, expected_titles|
                it_should_search_with_advanced_params(
                  {creator: qword, creator_merge: 'startwith'},
                  expected_titles)
              end
            end
          end
        end

        describe 'except_creatorが与えられたとき' do
          it '著者に指定語を含まないレコードを抽出すること' do
            it_should_search_with_advanced_params(
              {query: '北海道', except_creator: '青森 根室'},
              ['根室市北海道'])
          end
        end

        describe '各項目の検索語が与えられたとき' do
          before do
            @manifestation1 = FactoryGirl.create(
              :manifestation,
              original_title: '山形県米沢市',
              title_transcription: 'やまがたけんよねざわし',
              creators: [
                FactoryGirl.create(
                  :patron, full_name: '福島県郡山市',
                  full_name_transcription: 'ふくしまけんこおりやまし'),
              ],
              contributors: [
                FactoryGirl.create(
                  :patron, full_name: '茨城県水戸市',
                  full_name_transcription: 'いばらきけんみとし'),
              ],
              publishers: [
                FactoryGirl.create(
                  :patron, full_name: '栃木県宇都宮市',
                  full_name_transcription: 'とちぎけんうつのみやし'),
              ],
              isbn: '9784010000007', isbn10: '4010000007',
              issn: '10000003',
              nbn: '埼玉県川越市',
              manifestation_type: FactoryGirl.create(
                :manifestation_type,
                name: 'foo'))
            FactoryGirl.create(
              :item, manifestation: @manifestation1,
              item_identifier: 'somechar')
            @title1 = @manifestation1.original_title
            @typeid1 = @manifestation1.manifestation_type.id.to_s

            @manifestation2 = FactoryGirl.create(
              :manifestation,
              original_title: '亜',
              title_transcription: 'あ',
              creators: [
                FactoryGirl.create(
                  :patron, full_name: '衣',
                  full_name_transcription: 'い'),
              ],
              contributors: [
                FactoryGirl.create(
                  :patron, full_name: '宇',
                  full_name_transcription: 'う'),
              ],
              publishers: [
                FactoryGirl.create(
                  :patron, full_name: '絵',
                  full_name_transcription: 'え'),
              ],
              isbn: '9784020000004', isbn10: '402000000X',
              issn: '20000006',
              nbn: '尾',
              manifestation_type: FactoryGirl.create(
                :manifestation_type,
                name: 'bar'))
            FactoryGirl.create(
              :item, manifestation: @manifestation2,
              item_identifier: '1')
            @title2 = @manifestation2.original_title
            @typeid2 = @manifestation2.manifestation_type.id.to_s

            Sunspot.commit
          end

          it '指定条件で絞り込み抽出すること' do
            [
              # [param-name, query-word, [expected-original_title, ... ]],
              [:title, '米沢',      [@title1]],
              [:title, '米沢 山形', [@title1]],
              [:title, '米沢　山形',[@title1]],
              [:title, 'よねざわ',  [@title1]],
              [:title, 'よねさわ',  [@title1]],
              [:title, '米',        [@title1]],
              [:title, 'わ',        [@title1]],
              [:title, 'わ ね',     [@title1]],
              [:title, 'わ 米沢',   [@title1]],
              [:title, '亜',        [@title2]],
              [:title, 'あ',        [@title2, '秋田県', '秋田県能代市']],
              [:creator, '福島',      [@title1]],
              [:creator, '福島 郡山', [@title1]],
              [:creator, '福島　郡山',[@title1]],
              [:creator, 'ふくしま',  [@title1]],
              [:creator, '福',        [@title1]],
              [:creator, 'ふ',        [@title1]],
              [:creator, 'ふ や',     [@title1]],
              [:creator, 'ふ 郡山',   [@title1]],
              [:creator, '衣',        [@title2]],
              [:creator, 'い',        [@title2, '根室市北海道', '秋田県', '秋田県能代市']],
              [:contributor, '水戸',      [@title1]],
              [:contributor, '水戸 茨城', [@title1]],
              [:contributor, '水戸　茨城',[@title1]],
              [:contributor, 'みと',      [@title1]],
              [:contributor, '水',        [@title1]],
              [:contributor, 'み',        [@title1]],
              [:contributor, 'み と',     [@title1]],
              [:contributor, 'み 茨城',   [@title1]],
              [:contributor, '宇',        [@title2]],
              [:contributor, 'う',        [@title2]],
              [:publisher, '宇都宮',      [@title1]],
              [:publisher, '宇都宮 栃木', [@title1]],
              [:publisher, '宇都宮　栃木',[@title1]],
              [:publisher, 'うつのみや',  [@title1]],
              [:publisher, '都',          [@title1]],
              [:publisher, 'や',          [@title1]],
              [:publisher, 'や と',       [@title1]],
              [:publisher, 'や 栃木',     [@title1]],
              [:publisher, '絵',          [@title2]],
              [:publisher, 'え',          [@title2]],
              [:isbn, '9784010000007',  [@title1], true],
              [:isbn, '9784010000007*', [@title1], false],
              [:isbn, '4010000007',     [@title1]],
              [:isbn, '4010',           []],
              [:isbn, '4010*',          [@title1]],
              [:isbn, '978* *00X',      [@title2]],
              [:isbn, '978*　*00X',     [@title2]],
              [:isbn, '978 *00X',       []],
              [:isbn, '978* 00X',       []],
              [:isbn, '*X',             [@title2]],
              [:isbn, '*X*',            [@title2]],
              [:isbn, 'X',              []],
              [:isbn, 'X 978',          []],
              [:isbn, 'X 402000000X',   []],
              [:isbn, '*X 402000000X',  [@title2]],
              [:isbn, '*X 978*',        [@title2]],
              [:issn, '10000003',       [@title1]],
              [:issn, '100',            []],
              [:issn, '100*',           [@title1]],
              [:issn, '100* *003',      [@title1]],
              [:issn, '100* 003',       []],
              [:issn, '100 *003',       []],
              [:issn, '*3 10000003',    [@title1]],
              [:issn, '3 10000003',     []],
              [:nbn, '埼玉県川越市', [@title1]],
              [:nbn, '埼玉* *川越*', [@title1]],
              [:nbn, '埼玉*　*川越*',[@title1]],
              [:nbn, '埼玉 川越',    []],
              [:nbn, '埼玉* 川越',   []],
              [:nbn, '埼玉 *川越*',  []],
              [:nbn, '埼玉* *川越',  []],
              [:nbn, '埼玉* 川越*',  []],
              [:nbn, '玉',           []],
              [:nbn, '*玉*',         [@title1]],
              [:nbn, '玉 川',        []],
              [:nbn, '*玉* *川*',    [@title1]],
              [:nbn, '尾',           [@title2]],
              [:nbn, '尾*'  ,        [@title2]],
              [:item_identifier, 'somechar',   [@title1], true],
              [:item_identifier, 'somechar*',  [@title1], false],
              [:item_identifier, 'some char',  []],
              [:item_identifier, 'some*',      [@title1]],
              [:item_identifier, 'so* *char',  [@title1]],
              [:item_identifier, 'so*　*char', [@title1]],
              [:item_identifier, 's',          []],
              [:item_identifier, 's somechar', []],
              [:item_identifier, '1',          [@title2], true],
              [:item_identifier, '1*',         [@title2], false],
              [:manifestation_types,
                {@typeid1 => 'true'}, [@title1]],
              [:manifestation_types,
                {@typeid2 => 'true'},  [@title2]],
              [:manifestation_types,
                {@typeid1 => 'true', @typeid2 => 'true'},
                [@title1, @title2]],
              [:manifestation_types,
                {@typeid1 => 'true', (ManifestationType.last.id + 100).to_s => 'true'},
                [@title1]],
              [:manifestation_types, # 使われていないmanifestation_type
                {FactoryGirl.create(:manifestation_type, name: 'baz').id.to_s => 'true'},
                []],
              [:manifestation_types, # すべて無効なid
                {(ManifestationType.last.id + 100).to_s => 'true',
                  (ManifestationType.last.id + 200).to_s => 'true'},
                [@title1, @title2, '北海道', '北海道札幌市', '北海道千歳市', '根室市北海道', '秋田県', '秋田県能代市', '群馬県', '群馬県 前橋市', '前橋市 群馬県', '群馬県　高崎市', '高崎市　群馬県']],
              [:manifestation_types, # 指定なし
                {},
                [@title1, @title2, '北海道', '北海道札幌市', '北海道千歳市', '根室市北海道', '秋田県', '秋田県能代市', '群馬県', '群馬県 前橋市', '前橋市 群馬県', '群馬県　高崎市', '高崎市　群馬県']],
            ].each do |param, qword, expect_titles, direct_mode|
              it_should_search_with_advanced_params({param => qword, :direct_mode => direct_mode}, expect_titles)
            end

            if defined?(EnjuBookmark)
              pending 'tag指定検索についてのテストは未実施: EnjuBookmark利用に際しては実施すること'
            end
          end
        end
      end
    end

    describe 'indexパラメータがnacsisのとき' do
      include NacsisCatSpecHelper

      let(:nacsis_cat) { nacsis_cat_with_mock_record(:book) }
      let(:ncid) { nacsis_cat.record['ID'] }

      # NOTE:
      # config/config.yml->Setting->SystemConfig->per_pages
      # によるページネイトのデフォルトページ幅が10となる。
      # paramsで指定されない限り、
      # ManifestationsControllerでは
      # per_page=10が指定された状態で動作する。
      def reverse_merge_default_page_options(opts)
        return opts unless opts.is_a?(Hash)

        merged_db_opts = (opts[:opts] || {}).dup
        opts[:dbs].each do |db|
          h = (merged_db_opts[db] || {}).dup
          h[:page] ||= 1
          h[:per_page] ||= 10
          merged_db_opts[db] = h
        end
        opts.merge(:opts => merged_db_opts)
      end

      def nacsis_cat_should_receive_search_with(opts, return_value = nil)
        return_value ||= {}
        opts = reverse_merge_default_page_options(opts)
        NacsisCat.should_receive(:search).
          with(opts).and_return(return_value)
      end

      context 'nacsis.search_eachがtrueのとき' do
        before { set_nacsis_search_each(true) }

        it 'NACSIS-CAT検索を1回だけ実行すること' do
          nacsis_cat_should_receive_search_with(any_args)
          get :index, :index => 'nacsis', :ncid => ncid
          response.should be_success
        end
      end

      context 'nacsis.search_eachがfalseのとき' do
        before { set_nacsis_search_each(false) }

        it 'NACSIS-CAT検索を1回だけ実行すること' do
          nacsis_cat_should_receive_search_with(any_args)
          get :index, :index => 'nacsis', :ncid => ncid
          response.should be_success
        end
      end

      it '検索条件が空のとき@manifestationsを空にすること' do
        NacsisCat.should_not_receive(:http_get_value)

        get :index, :index => 'nacsis'
        response.should be_success
        assigns(:manifestations).should eq(NacsisCat::ResultArray.new(nil))
      end

      describe '書誌の種類の指定がないとき' do
        context 'nacsis.search_eachがtrueなら' do
          before { set_nacsis_search_each(true) }
          it '一般および雑誌の書誌を検索対象とすること' do
            nacsis_cat_should_receive_search_with(:dbs => [:book, :serial], :id => 'foo')
            get :index, :index => 'nacsis', :ncid => 'foo'
          end
        end

        context 'nacsis.search_eachがfalseなら' do
          before { set_nacsis_search_each(false) }
          it '全書誌を検索対象とすること' do
            nacsis_cat_should_receive_search_with(:dbs => [:all], :id => 'foo')
            get :index, :index => 'nacsis', :ncid => 'foo'
          end
        end
      end

      describe '書誌の種類の指定がbookとserialのとき' do
        context 'nacsis.search_eachがtrueなら' do
          before { set_nacsis_search_each(true) }
          it '一般および雑誌の書誌を検索対象とすること' do
            nacsis_cat_should_receive_search_with(:dbs => [:book, :serial], :id => 'foo')
            get :index, :index => 'nacsis', :ncid => 'foo', :manifestation_type => %w(book serial)
          end
        end

        context 'nacsis.search_eachがfalseなら' do
          before { set_nacsis_search_each(false) }
          it '全書誌を検索対象とすること' do
            nacsis_cat_should_receive_search_with(:dbs => [:all], :id => 'foo')
            get :index, :index => 'nacsis', :ncid => 'foo', :manifestation_type => %w(book serial)
          end
        end
      end

      it '書誌の種類の指定がbookのとき、一般書誌を検索対象とすること' do
        nacsis_cat_should_receive_search_with(:dbs => [:book], :id => 'foo')
        get :index, :index => 'nacsis', :ncid => 'foo', :manifestation_type => %w(book)
      end

      it '書誌の種類の指定がserialのとき、雑誌書誌を検索対象とすること' do
        nacsis_cat_should_receive_search_with(:dbs => [:serial], :id => 'foo')
        get :index, :index => 'nacsis', :ncid => 'foo', :manifestation_type => %w(serial)
      end

      it '検索条件が否定形のみのとき@manifestationsを空にすること' do
        NacsisCat.should_not_receive(:http_get_value)

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
            nacsis_cat_should_receive_search_with(sname => 'foo bar', :dbs => [:book, :serial])
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
            nacsis_cat_should_receive_search_with(sname => ['foo', 'bar'], :dbs => [:book, :serial])
            get :index, :index => 'nacsis',
              name => 'foo bar'
            response.should be_success
          end
        end

        describe "except_#{name}パラメータが指定されたとき" do
          it "否定形#{name.inspect}でNacsisCat.searchを実行すること" do
            nacsis_cat_should_receive_search_with(sname => ['foo', 'bar'], :except => {sname => ['baz']}, :dbs => [:book, :serial])
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
      search = ManifestationsController::NacsisCatSearch.new([:book, :serial])
      search.filter_by_record_type!('book')
      NacsisCat.should_receive(:search)
      search.execute

      search = ManifestationsController::NacsisCatSearch.new([:book])
      search.filter_by_record_type!('book')
      NacsisCat.should_receive(:search)
      search.execute

      search = ManifestationsController::NacsisCatSearch.new([:all])
      search.filter_by_record_type!('book')
      NacsisCat.should_receive(:search)
      search.execute

      search = ManifestationsController::NacsisCatSearch.new([:book])
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

    describe '#setup_paginate!は' do
      it '検索実行時に渡すpaginateオプションを設定すること' do
        NacsisCat.should_receive(:search).
          with(:opts => {:book => {:per_page => 10, :page => 1}}, :dbs => [:book]).
          and_return(NacsisCat::ResultArray.new(nil))

        search = ManifestationsController::NacsisCatSearch.new([:book])
        search.setup_paginate!(:book, '1', '10') # フォーム入力がそのまま渡るのでNacsisCatSearch#per_pageの引数は文字列となる(内部で数値に変換してNacsisCatに渡す)
        search.execute
      end
    end

  end
end
