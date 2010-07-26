module GoogleMap

  class GeoXml
    #include Reloadable
    include UnbackedDomId
  
    attr_accessor :url_of_xml
  
    def initialize(options = {})
      options.each_pair { |key, value| send("#{key}=", value) }
    end
    
    def to_js
    
      js = []
      js << "#{dom_id} = new GGeoXml('#{url_of_xml}');"

      js.join "\n"
    end  
  end

end
