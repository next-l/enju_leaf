module EnjuCalilLibrary
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_calil_library
      include EnjuCalilLibrary::InstanceMethods
    end
  end

  module InstanceMethods
    def access_calil
      if configatron.calil.app_key == 'REPLACE_WITH_YOUR_CALIL_APP_KEY'
        Rails.logger.error "Calil access key is not set"
        return nil
      end
      if self.latitude.present? and self.longitude.present?
        calil_url = "http://api.calil.jp/library?appkey=#{configatron.calil.app_key}&geocode=#{self.longitude},#{self.latitude}"
        open(calil_url) do |f|
          f.read
        end
      end
    end

    def access_calil_systemid(systemid)
      calil_url = "http://api.calil.jp/library?appkey=#{configatron.calil.app_key}&systemid=#{systemid}"
      open(calil_url) do |f|
        f.read
      end
    end

    def calil_library(xml)
      doc = Nokogiri::XML(xml)
      libraries = []
      doc.xpath('/Libraries/Library').each do |d|
        library = {
          :systemid => d.at('systemid').content,
          :systemname => d.at('libkey').content,
          :short => d.at('short').content,
          :formal => d.at('formal').content,
          :url_pc => d.at('url_pc').content,
          :address => d.at('address').content,
          :pref => d.at('pref').content,
          :city => d.at('city').content,
          :post => d.at('post').content,
          :tel => d.at('tel').content,
          :geocode => d.at('geocode').content,
          :category => d.at('category').content,
          #:image => d.at('image').content
        }
        libraries << library
      end
      libraries
    #rescue NoMethodError
    #  nil
    end

    def calil_neighborhood_systems
      systemid = self.calil_neighborhood_systemid
      if systemid
        self.calil_neighborhood_systemid.split(',')[0..2]
      else
        []
      end
    end

  end
end
