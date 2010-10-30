module EnjuCalilCheck
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_calil_check
      include EnjuCalilCheck::InstanceMethods
    end
  end

  module InstanceMethods
    def access_calil(systemid, format = 'xml')
      if configatron.calil.app_key == 'REPLACE_WITH_YOUR_CALIL_APP_KEY'
        Rails.logger.error "Calil access key is not set"
        return nil
      end
      if self.isbn.present?
        open( "http://api.calil.jp/check?appkey=#{configatron.calil.app_key}&isbn=#{self.isbn}&systemid=#{systemid.join(',')}&format=#{format}") do |f|
          f.read
        end
      end
    end

    def calil_session(systemid)
      response = access_calil(systemid)
      doc = Nokogiri::XML(response)
      doc.at('/result/session').content
    end

    def access_calil_polling(session, format = 'xml')
      url = "http://api.calil.jp/check?appkey=#{configatron.calil.app_key}&session=#{session}&format=#{format}"
      open("http://api.calil.jp/check?appkey=#{configatron.calil.app_key}&session=#{session}&format=#{format}") do |f|
        f.read
      end
    end

    def calil_check(response, format = 'xml')
      doc = Nokogiri::XML(response)
      case format
      when 'xml'
        continue = true
        3.times do
          break if doc.at('/result/continue').content.to_i == 0 rescue nil
          sleep 2
          session = doc.at('/result/session').content.to_s rescue nil
          response = access_calil_polling(session)
          Rails.logger.info 'getting response from calil...'
          Rails.logger.info doc.to_s
          doc = Nokogiri::XML(response)
        end
        session = doc.at('/result/session').content.to_s
        continue = doc.at('/result/continue').content
        libraries = doc.xpath('/result/books').map do |d|
              library = {
                :isbn => d.at('book').attributes['isbn'].value,
                :calilurl => d.at('book').attributes['calilurl'].value,
                :system => d.xpath('book/system').map do |s|
                  system = {
                    :status => s.at('status').content,
                    :reserveurl => s.at('reserveurl').content,
                    :libkeys => s.xpath('libkeys').map do |e|
                      if e.at('libkey')
                        {:name => e.at('libkey').attributes['name'].content, :key => e.at('libkey').content}
                      end
                    end
                  }
                end
              }
        end
        {:session => session, :continue => continue, :response => libraries}
      when 'json'
      end
    #rescue NoMethodError
    #  nil
    end

  end
end
