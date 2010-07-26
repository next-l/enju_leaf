module GoogleMap

  class Polyline
    #include Reloadable
    include UnbackedDomId

    attr_accessor :dom_id,
                  :map,
                  :vertices,
                  :color,
                  :weight,
                  :opacity

    def initialize(options = {})
      self.vertices = []
      self.color = "#000"
      self.weight = 1
      self.opacity = 1
      options.each_pair { |key, value| send("#{key}=", value) }
      if !map or !map.kind_of?(GoogleMap::Map)
        raise "Must set map for GoogleMap::Polyline."
      end
      if dom_id.blank?
        # This needs self to set the attr_accessor, why?
        self.dom_id = "#{map.dom_id}_marker_#{map.markers.size + 1}"
      end
    end
            
    def to_js

      js = []
      js << "#{dom_id}_vertices = new Array();"
      vertices.each_with_index do |point, index|
        js << "#{dom_id}_vertices[#{index}] = new GLatLng(#{point.lat}, #{point.lng});"
      end

      js << "#{dom_id} = new GPolyline(#{dom_id}_vertices, '#{color}', #{weight}, #{opacity});"

      js.join "\n"
    end
  end
  
end