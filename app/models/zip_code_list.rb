class ZipCodeList < ActiveRecord::Base

  searchable do
    text :prefecture_name, :city_name, :region_name
  end

  def self.import(filename = nil)
    zipcode_import = self.new
    rows = zipcode_import.open_import_file(filename)
    ZipCodeList.delete_all

    rows.each do |row|
      h = {}
      h[:union_code] = row[0]
      h[:zipcode7] = row[2]
      h[:prefectrure_name_kana] = row[3]
      h[:city_name_kana] = row[4]
      h[:region_name_kana] = row[5]
      h[:prefecture_name] = row[6]
      h[:city_name] = row[7]
      h[:region_name] = row[8]
      h[:flag10] = row[9]
      h[:flag11] = row[10]
      h[:flag12] = row[11]
      h[:flag13] = row[12]
      h[:flag14] = row[13]
      h[:update_flag] = row[14]
      ZipCodeList.create!(h)
    end

  end

  def open_import_file(upload_file_path)
    tempfile = Tempfile.new('zipcode_import_file')
    #TODO
    open(upload_file_path){|f|
      f.each{|line|
        tempfile.puts(NKF.nkf('-w -Lu', line))
      }
    }
    tempfile.close

    file = CSV.open(tempfile.path, :col_sep => "\t")
    #header = file.first
    #rows = CSV.open(tempfile.path, :headers => header, :col_sep => "\t")
    rows = CSV.open(tempfile.path)

    #ResourceImportResult.create(:resource_import_file => self, :body => header.join("\t"), :error_msg => "HEADER DATA")
    tempfile.close(true)
    file.close
    rows
  end
end
