# encoding: utf-8

module NacsisCatSpecHelper
  def nacsis_record_object(record_type = :book)
    book_attrs = {
      '_DBNAME_' => 'BOOK',
      'ID' => 'XX00000001',
      'TR' => {
        'TRD' => '本標題:標題関連情報/責任表示',
        'TRR' => 'ホンヒョウダイ ヨミ',
      },
      'PUB' => [
        {
          'PUBL' => '出版者1',
          'PUBDT' => '2013.6', # 出版年月等
          'PUBP' => '出版地a',
        },
        {
          'PUBL' => '出版者2',
          'PUBDT' => '2013.7', # 出版年月等
          'PUBP' => '出版地b',
        },
      ],
      'YEAR' => {
        'YEAR1' => '2012', # 出版開始年,
        'YEAR2' => nil, # 出版終了年
      },
      'PTBL' => [
        {'PTBTR' => '親書誌1標題', 'PTBNO' => '123'},
        {'PTBTR' => '親書誌2標題', 'PTBNO' => nil},
      ],
      'CLS' => [
        {'CLSD' => '分類a', 'CLSK' => '分類の種類1'},
        {'CLSD' => '分類b', 'CLSK' => '分類の種類9'},
      ],
      'PHYS' => {
        'PHYSP' => '237p',
        'PHYSI' => 'll.',
        'PHYSS' => '23cm',
        'PHYSA' => 'CD-ROM',
      },
      'AL' => [
        {'AHDNG' => '著者1標目形', 'AHDNGR' => 'チョシャ1 ヨミ'},
        {'AHDNG' => '著者2標目形', 'AHDNGR' => 'チョシャ2 ヨミ'},
      ],
      'NOTE' => %w(注記1 注記2),
      'VOLG' => [
        {'ISBN' => '9780000000019'},
        {'ISBN' => '9780000000026'},
      ],
      'CNTRY' => 'ja', # 出版国
      'TTLL' => 'jpn', # 本標題の言語コード
      'TXTL' => 'jpn', # 本文の言語コード
      'SH' => [
        {'SHD' => '件名1'},
        {'SHD' => '件名2'},
      ],
    }

    serial_attrs = {
      '_DBNAME_' => 'SERIAL',
      'ID' => 'XX00000001',
      'ISSN' => '9780000000019',
      'TR' => {
        'TRD' => '本標題:標題関連情報/責任表示',
        'TRR' => 'ホンヒョウダイ ヨミ',
      },
      'AL' => [
        {'AHDNG' => '著者1標目形', 'AHDNGR' => 'チョシャ1 ヨミ'},
        {'AHDNG' => '著者2標目形', 'AHDNGR' => 'チョシャ2 ヨミ'},
      ],
      'YEAR' => {
        'YEAR1' => '2012', # 出版開始年,
        'YEAR2' => nil, # 出版終了年
      },
      'PUB' => [
        {
          'PUBL' => '出版者1',
          'PUBDT' => '2013.6', # 出版年月等
          'PUBP' => '出版地a',
        },
        {
          'PUBL' => '出版者2',
          'PUBDT' => '2013.7', # 出版年月等
          'PUBP' => '出版地b',
        },
      ],
      'VLYR' => %w(1集 Vol.1),
      'CNTRY' => 'ja', # 出版国
      'TTLL' => 'jpn', # 本標題の言語コード
      'TXTL' => 'jpn', # 本文の言語コード
      'SH' => [
        {'SHD' => '件名1'},
        {'SHD' => '件名2'},
      ],
      'NOTE' => %w(注記1 注記2),
      'PHYS' => {
        'PHYSP' => '237p',
        'PHYSI' => 'll.',
        'PHYSS' => '23cm',
        'PHYSA' => 'CD-ROM',
      },
    }

    record_type == :book ? book_attrs : serial_attrs
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
end
