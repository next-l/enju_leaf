# encoding: utf-8

module NacsisCatSpecHelper
  def nacsis_record_object(record_type = :book)
    book_attrs = {
      :bibliog_id => 'XX00000001',
      :tr => {
        :trd => '本標題:標題関連情報/責任表示',
        :trr => 'ホンヒョウダイ ヨミ',
      },
      :pubs => [
        {
          :publ => '出版者1',
          :pubdt => '2013.6', # 出版年月等
          :pubp => '出版地a',
        },
        {
          :publ => '出版者2',
          :pubdt => '2013.7', # 出版年月等
          :pubp => '出版地b',
        },
      ],
      :year => {
        :year1 => '2012', # 出版開始年,
        :year2 => nil, # 出版終了年
      },
      :ptbls => [
        {:ptbtr => '親書誌1標題', :ptbno => '123'},
        {:ptbtr => '親書誌2標題', :ptbno => nil},
      ],
      :cls => [
        {:clsd => '分類a', :clsk => '分類の種類1'},
        {:clsd => '分類b', :clsk => '分類の種類9'},
      ],
      :phys => {
        :physp => '237p',
        :physi => 'll.',
        :physs => '23cm',
        :physa => 'CD-ROM',
      },
      :als => [
        {:ahdng => '著者1標目形', :ahdngr => 'チョシャ1 ヨミ'},
        {:ahdng => '著者2標目形', :ahdngr => 'チョシャ2 ヨミ'},
      ],
      :notes => %w(注記1 注記2),
      :volgs => [
        {:isbn => '9780000000019'},
        {:isbn => '9780000000026'},
      ],
      :cntry => 'ja', # 出版国
      :ttll => 'jpn', # 本標題の言語コード
      :txtl => 'jpn', # 本文の言語コード
      :shs => [
        {:shd => '件名1'},
        {:shd => '件名2'},
      ],
    }

    serial_attrs = {
      :dbname => 'SERIAL',
      :bibliog_id => 'XX00000001',
      :issn => '9780000000019',
      :tr => {
        :trd => '本標題:標題関連情報/責任表示',
        :trr => 'ホンヒョウダイ ヨミ',
      },
      :als => [
        {:ahdng => '著者1標目形', :ahdngr => 'チョシャ1 ヨミ'},
        {:ahdng => '著者2標目形', :ahdngr => 'チョシャ2 ヨミ'},
      ],
      :year => {
        :year1 => '2012', # 出版開始年,
        :year2 => nil, # 出版終了年
      },
      :pubs => [
        {
          :publ => '出版者1',
          :pubdt => '2013.6', # 出版年月等
          :pubp => '出版地a',
        },
        {
          :publ => '出版者2',
          :pubdt => '2013.7', # 出版年月等
          :pubp => '出版地b',
        },
      ],
      :vlyrs => %w(1集 Vol.1),
      :cntry => 'ja', # 出版国
      :ttll => 'jpn', # 本標題の言語コード
      :txtl => 'jpn', # 本文の言語コード
      :shs => [
        {:shd => '件名1'},
        {:shd => '件名2'},
      ],
      :notes => %w(注記1 注記2),
      :phys => {
        :physp => '237p',
        :physi => 'll.',
        :physs => '23cm',
        :physa => 'CD-ROM',
      },
    }

    set_stub = proc do |target, hash|
      hash.each_pair do |key, value|
        case value
        when Array
          value = value.map do |v|
            if v.is_a?(Hash)
              Object.new.tap {|o| set_stub.call(o, v) }
            else
              v
            end
          end
        when Hash
          value = Object.new.tap {|o| set_stub.call(o, value) }
        end
        target.stub(key => value)
      end
    end

    attrs = record_type == :book ? book_attrs : serial_attrs
    Object.new.tap do |o|
      set_stub.call(o, attrs)
    end
  end

  # EnjuNacsisCatp::BookInfo、EnjuNacsisCatp::SerialInfoの
  # ふりをするオブジェクトを返す。
  # 引数は:bookまたは:serial。
  def nacsis_cat_with_mock_record(record_type = :book)
    NacsisCat.new(:record => nacsis_record_object(record_type)).tap do |nc|
      nc.stub(:serial? => record_type == :book ? false : true)
      nc.stub(:item? => false)
    end
  end

  # enju_nacsis_gw_clientの挙動を上書きし、result_specで指定した検索結果を返させる
  def set_nacsis_cat_gw_client_stub(result_specs, method = :should_receive)
    objs = [result_specs].flatten.map do |result_spec|
      Object.new.tap do |obj|
        result_spec.each_pair {|name, value| obj.stub(name => value) }
      end
    end

    EnjuNacsisCatp::CatGatewayClient.any_instance.
      __send__(method, :execute).and_return(*objs)
  end
end
