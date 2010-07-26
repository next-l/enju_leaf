module GoogleMap
  class Map
    #include Reloadable
    include UnbackedDomId
    attr_accessor :dom_id,
      :markers,
      :overlays,
      :controls,
      :inject_on_load,
      :zoom,
      :center,
      :double_click_zoom,
      :continuous_zoom,
      :scroll_wheel_zoom,
      :bounds,
      :map_type

    def initialize(options = {})
      self.dom_id = 'google_map'
      self.markers = []
      self.overlays = []
      self.bounds = []
      self.controls = [ :large, :scale, :type ]
      self.double_click_zoom = true
      self.continuous_zoom = false
      self.scroll_wheel_zoom = false
      options.each_pair { |key, value| send("#{key}=", value) }
    end

    def to_html
      html = []

      html << "<script src='http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{GOOGLE_APPLICATION_ID}' type='text/javascript'></script>"    
      html << "<script type=\"text/javascript\">\n/* <![CDATA[ */\n"  
      html << to_js
      html << "/* ]]> */</script> "

      return html.join("\n")
    end

    def to_enable_prefix true_or_false
      true_or_false ? "enable" : "disable"
    end

    def to_js
      js = []

      # Initialise the map variable so that it can externally accessed.
      js << "var #{dom_id};"
      
      markers.each { |marker| js << "var #{marker.dom_id};" }

      js << markers_functions_js
      js << center_map_js

      js << "function initialize_google_map_#{dom_id}() {"
      js << "  if(GBrowserIsCompatible()) {"
      js << "    #{dom_id} = new GMap2(document.getElementById('#{dom_id}'));"

      js << "    if (self['GoogleMapOnLoad']) {"
      js << "      #{dom_id}.load = GEvent.addListener(#{dom_id},'load',GoogleMapOnLoad)"
      js << "    }"

      js << '    ' + map_type_js
      js << '    ' + controls_js
      js << '    ' + center_on_bounds_js
      js << '    ' + markers_icons_js

      # Put all the markers on the map.
      for marker in markers
        js << '    ' + marker.to_js
        js << ''
      end

      overlays.each do |overlay|
        js << overlay.to_js
        js << "#{dom_id}.addOverlay(#{overlay.dom_id});"  
      end

      js << "#{dom_id}.#{to_enable_prefix double_click_zoom}DoubleClickZoom();"
      js << "#{dom_id}.#{to_enable_prefix continuous_zoom}ContinuousZoom();"
      js << "#{dom_id}.#{to_enable_prefix scroll_wheel_zoom}ScrollWheelZoom();"

      js << '    ' + inject_on_load.gsub("\n", "    \n") if inject_on_load
      js << "  }"
      js << "}"

      # Load the map on window load preserving anything already on window.onload.
      js << "if (typeof window.onload != 'function') {"
      js << "  window.onload = initialize_google_map_#{dom_id};"
      js << "} else {"
      js << "  old_before_google_map_#{dom_id} = window.onload;"
      js << "  window.onload = function() {" 
      js << "    old_before_google_map_#{dom_id}();"
      js << "    initialize_google_map_#{dom_id}();"
      js << "  }"
      js << "}"

      # Unload the map on window load preserving anything already on window.onunload.
      #js << "if (typeof window.onunload != 'function') {"
      #js << "  window.onunload = GUnload();"
      #js << "} else {"
      #js << "  old_before_onunload = window.onload;"
      #js << "  window.onunload = function() {" 
      #js << "    old_before_onunload;"
      #js << "    GUnload();" 
      #js << "  }"
      #js << "}"

      return js.join("\n")
    end

    def map_type_js
      js = []
      if map_type
        js << "#{dom_id}.setMapType(#{map_type});"
      end    
      js.join("\n")
    end

    def controls_js
      js = []

      controls.each do |control|
        case control
        when :large, :small, :overview
          c = "G#{control.to_s.capitalize}MapControl"
        when :large_3d
          c = "GLargeMapControl3D"
        when :scale
          c = "GScaleControl"
        when :type
          c = "GMapTypeControl"
        when :menu_type
          c = "GMenuMapTypeControl"
        when :hierachical_type
          c = "GHierarchicalMapTypeControl"
        when :zoom
          c = "GSmallZoomControl"
        when :zoom_3d
          c = "GSmallZoomControl3D"
        when :nav_label
          c = "GNavLabelControl"
        end
        js << "#{dom_id}.addControl(new #{c}());"
      end

      return js.join("\n")
    end

    def markers_functions_js
      js = []
      for marker in markers
        js << marker.open_info_window_function
      end
      return js.join("\n")
    end

    def markers_icons_js
      icons = []
      for marker in markers
        if marker.icon and !icons.include?(marker.icon)
          icons << marker.icon 
        end
      end
      js = []
      for icon in icons
        js << icon.to_js
      end
      return js.join("\n")
    end

    # Creates a JS function that centers the map on the specified center
    # location if given to the initialisers, or on the maps markers if they exist, or
    # at (0,0) if not.
    def center_map_js
      if self.zoom
        zoom_js = zoom
      else
        zoom_js = "#{dom_id}.getBoundsZoomLevel(#{dom_id}_latlng_bounds)"
      end
      set_center_js = []
      
      if self.center
        set_center_js << "#{dom_id}.setCenter(new GLatLng(#{center.lat}, #{center.lng}), #{zoom_js});"
      else
        synch_bounds
        set_center_js << "var #{dom_id}_latlng_bounds = new GLatLngBounds();"
        
        bounds.each do |point|
          set_center_js << "#{dom_id}_latlng_bounds.extend(new GLatLng(#{point.lat}, #{point.lng}));"
        end  
        
        set_center_js << "#{dom_id}.setCenter(#{dom_id}_latlng_bounds.getCenter(), #{zoom_js});"
      end
      
      "function center_#{dom_id}() {\n  #{check_resize_js}\n  #{set_center_js.join "\n"}\n}"
    end

    def synch_bounds
      
      overlays.each do |overlay|
        if overlay.is_a? GoogleMap::Polyline
          overlay.vertices.each do |v|
            bounds << v #i do not like this inconsistent interface
          end 
        end
      end
      
      markers.each do |m|
        bounds << m
      end    
      
      bounds.uniq!
    end

    def check_resize_js
      return "#{dom_id}.checkResize();"
    end

    def center_on_bounds_js
      return "center_#{dom_id}();"
    end

    def div(width = '100%', height = '100%')
      "<div id='#{dom_id}' style='width: #{width}; height: #{height}'></div>"
    end

  end
end

# class Map
#   #include Reloadable
#   include UnbackedDomId
#   attr_accessor :dom_id,
#     :markers,
#     :polylines,
#     :controls,
#     :inject_on_load,
#     :zoom
# 
#   def initialize(options = {})
#     self.dom_id = 'google_map'
#     self.markers = []
#     self.polylines = []
#     self.controls = [ :zoom, :overview, :scale, :type ]
#     options.each_pair { |key, value| send("#{key}=", value) }
#   end
# 
#   def to_html
#     html = []
# 
#     html << "<script src='http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{GOOGLE_APPLICATION_ID}' type='text/javascript'></script>"    
#     html << "<script type=\"text/javascript\">\n/* <![CDATA[ */\n"  
#     html << to_js
#     html << "/* ]]> */</script> "
# 
#     return html.join("\n")
#   end
# 
#   def to_js
#     js = []
# 
#     # Initialise the map variable so that it can externally accessed.
#     js << "var #{dom_id};"
#     
#     markers.each { |marker| js << "var #{marker.dom_id};" }
# 
#     js << markers_functions_js
# 
#     js << center_on_markers_function_js
# 
#     js << "function initialize_google_map_#{dom_id}() {"
#     js << "  if(GBrowserIsCompatible()) {"
#     js << "    #{dom_id} = new GMap2(document.getElementById('#{dom_id}'));"
# 
#     js << " if (self['GoogleMapOnLoad']) {"
#     #   added by Patrick to enable load functions
#     js << "#{dom_id}.load = GEvent.addListener(#{dom_id},'load',GoogleMapOnLoad)"
#     js << "}"
#     js << '    ' + controls_js
# 
#     js << '    ' + center_on_markers_js
# 
#     js << '    ' + markers_icons_js
# 
#     # Put all the markers on the map.
#     for marker in markers
#       js << '    ' + marker.to_js
#       js << ''
#     end
# 
#     for polyline in polylines
#       js << '    ' + polyline.to_js
#       js << ''
#     end
#     
#     js << '    ' + inject_on_load.gsub("\n", "    \n") if inject_on_load
#     js << "  }"
#     js << "}"
# 
#     # Load the map on window load preserving anything already on window.onload.
#     js << "if (typeof window.onload != 'function') {"
#     js << "  window.onload = initialize_google_map_#{dom_id};"
#     js << "} else {"
#     js << "  old_before_google_map_#{dom_id} = window.onload;"
#     js << "  window.onload = function() {" 
#     js << "    old_before_google_map_#{dom_id}();"
#     js << "    initialize_google_map_#{dom_id}();"
#     js << "  }"
#     js << "}"
# 
#     # Unload the map on window load preserving anything already on window.onunload.
#     #js << "if (typeof window.onunload != 'function') {"
#     #js << "  window.onunload = GUnload();"
#     #js << "} else {"
#     #js << "  old_before_onunload = window.onload;"
#     #js << "  window.onunload = function() {" 
#     #js << "    old_before_onunload;"
#     #js << "    GUnload();" 
#     #js << "  }"
#     #js << "}"
# 
#     return js.join("\n")
#   end
# 
#   def controls_js
#     js = []
# 
#     controls.each do |control|
#       case control
#       when :large, :small, :overview
#         c = "G#{control.to_s.capitalize}MapControl"
#       when :scale
#         c = "GScaleControl"
#       when :type
#         c = "GMapTypeControl"
#       when :zoom
#         c = "GSmallZoomControl"
#       end
#       js << "#{dom_id}.addControl(new #{c}());"
#     end
# 
#     return js.join("\n")
#   end
# 
#   def markers_functions_js
#     js = []
# 
#     for marker in markers
#       js << marker.open_info_window_function
#     end
# 
#     return js.join("\n")
#   end
# 
#   def markers_icons_js
#     icons = []
# 
#     for marker in markers
#       if marker.icon and !icons.include?(marker.icon)
#         icons << marker.icon 
#       end
#     end
# 
#     js = []
# 
#     for icon in icons
#       js << icon.to_js
#     end
# 
#     return js.join("\n")
#   end
# 
#   # Creates a JS function that centers the map on its markers.
#   def center_on_markers_function_js
#     if markers.size == 0 and polylines.size == 0
#       set_center_js = "#{dom_id}.setCenter(new GLatLng(0, 0), 0);"
#     else
# 
#       for marker in markers
#         min_lat = marker.lat if !min_lat or marker.lat < min_lat
#         max_lat = marker.lat if !max_lat or marker.lat > max_lat
#         min_lng = marker.lng if !min_lng or marker.lng < min_lng
#         max_lng = marker.lng if !max_lng or marker.lng > max_lng
#       end
# 
#       for polyline in polylines
#         polyline.points.each do |point|
#           min_lat = point.lat if !min_lat or point.lat < min_lat
#           max_lat = point.lat if !max_lat or point.lat > max_lat
#           min_lng = point.lng if !min_lng or point.lng < min_lng
#           max_lng = point.lng if !max_lng or point.lng > max_lng
#         end
#       end
#       
#       # if no markers or polyline points zero values
#       min_lat ? min_lat : 0
#       max_lat ? max_lat : 0
#       min_lng ? min_lng : 0
#       max_lng ? max_lng : 0
#      
#       if self.zoom
#         zoom_js = zoom
#       else
#         bounds_js = "new GLatLngBounds(new GLatLng(#{min_lat}, #{min_lng}), new GLatLng(#{max_lat}, #{max_lng}))"
#         zoom_js = "#{dom_id}.getBoundsZoomLevel(#{bounds_js})"
#       end
# 
#       center_js = "new GLatLng(#{(min_lat + max_lat) / 2}, #{(min_lng + max_lng) / 2})"
#       set_center_js = "#{dom_id}.setCenter(#{center_js}, #{zoom_js});"
#     end
# 
#     return "function center_#{dom_id}() {\n  #{check_resize_js}\n  #{set_center_js}\n}"
#   end
# 
#   def check_resize_js
#     return "#{dom_id}.checkResize();"
#   end
# 
#   def center_on_markers_js
#     return "center_#{dom_id}();"
#   end
# 
#   def div(width = '100%', height = '100%')
#     "<div id='#{dom_id}' style='width: #{width}; height: #{height}'></div>"
#   end
# 
# end

