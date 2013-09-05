require 'axlsx'
require 'tempfile'

module Axlsx

  # Axslx 1.3.6のSimpleTypedListを以下のように改変
  #  * #initialize - XML化テキスト用の一時ファイルをオープンする
  #  * #<< - 与えられたオブジェクトを内部で保持し、それまでに保持していたオブジェクトを一時ファイルに書き出すとともに破棄する
  #  * #to_xml_string - 一時ファイルの内容を使って出力する
  class FileBasedSimpleTypedList < SimpleTypedList
    def initialize type, serialize_as=nil
      super
      @list_size = 0
      @xml = Tempfile.new('axlsx_file_based_simple_typed_list', :encoding => 'BINARY')
    end

    def <<(v)
      DataTypeValidator.validate "SimpleTypedList.<<", @allowed_types, v
      flush_last_item_to_tempfile
      @list_size += 1
      @list = [v]
    end

    def to_xml_string(str = '')
      flush_last_item_to_tempfile

      classname = @allowed_types[0].name.split('::').last
      el_name = serialize_as.to_s || (classname[0,1].downcase + classname[1..-1])
      str << '<' << el_name << ' count="' << @list_size.to_s << '">'
      @xml.rewind
      while data = @xml.read(1024)
        str << data
      end
      @xml.close
      str << '</' << el_name << '>'
    end

    private

      def flush_last_item_to_tempfile
        return if @list.empty?
        @xml.print @list.last.to_xml_string(@list_size - 1)
        @xml.flush
      end
  end

  # Axslx 1.3.6のSheetDatを以下のように改変
  #  * #to_xml_string - worksheet.rowsに直接アクセスせず、rows.to_xml_stringを使う(FileBasedSimpleTypedList#to_xml_stringを使うため)
  class AppendOnlySheetData < SheetData
    def to_xml_string(str = '')
      worksheet.rows.to_xml_string(str)
    end
  end

  # Axslx 1.3.6のWorksheetを以下のように改変
  #  * #rows - SimpleTypedListの代わりにFileBasedSimpleTypedListを使う
  #  * #wheet_data - SeetDataの代わりにAppendOnlySheetDataを使う
  #  * #to_xml_string
  #     * auto_filterを無視する
  #     * XMLテキストをTempfileに出力する
  #     * Tempfileを返す
  #  * #sanitize
  #     * ファイルの内容を対象としてもともとのsanitizeを適用する
  #     * Fileを受け取り、Fileを返す
  class AppendOnlyWorksheet < Worksheet
    def rows
      @rows ||= FileBasedSimpleTypedList.new Row, 'sheetData'
    end

    def sheet_data
      @sheet_data ||= AppendOnlySheetData.new self
    end

    def to_xml_string
      file = Tempfile.new('axlsx_append_only_worksheet', :encoding => 'BINARY')
      file << '<?xml version="1.0" encoding="UTF-8"?>'
      file << worksheet_node
      serializable_parts.each do |item|
        item.to_xml_string(file) if item
      end
      file << '</worksheet>'
      file.flush
      sanitize(file)
    end

    def sanitize file
      file.rewind
      tmp = Tempfile.new('axlsx_append_only_worksheet', :encoding => 'BINARY')
      while data = file.read(1024)
        tmp.write super(data)
      end

      file.rewind
      tmp.rewind
      pos = IO.copy_stream(tmp, file)
      file.flush
      file.truncate(pos)
      tmp.close(true)

      file
    end

  end

  # Axslx 1.3.6のPackage#write_patsに以下の機能を追加
  #  * #write_parts - part[:doc]がreadに応答するとき、1024バイトずつreadしてzipストリームに書き出す(メモリ消費をおさえるため)
  class Package

    def write_parts(zip)
      p = parts
      p.each do |part|
        unless part[:doc].nil?
          zip.put_next_entry(part[:entry])
          if part[:doc].respond_to?(:read)
            part[:doc].rewind
            while text = part[:doc].read(1024)
              text = ['1.9.2', '1.9.3'].include?(RUBY_VERSION) ? text.force_encoding('BINARY') : text
              zip.write(text)
            end
            part[:doc].close
            zip.write("\n") unless /\n\z/ =~ text
          else
            entry = ['1.9.2', '1.9.3'].include?(RUBY_VERSION) ? part[:doc].force_encoding('BINARY') : part[:doc]
            zip.puts(entry)
          end
        end
        unless part[:path].nil?
          zip.put_next_entry(part[:entry]);
          # binread for 1.9.3
          zip.write IO.respond_to?(:binread) ? IO.binread(part[:path]) : IO.read(part[:path])
        end
      end
      zip
    end

  end
end
