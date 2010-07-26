module GoogleMap
  
  class SmallIcon < GoogleMap::Icon
    #include Reloadable

    alias_method :parent_initialize, :initialize

    def initialize( map, color = 'red')
      parent_initialize(:width => 12,
                        :height => 20,
                        :shadow_width => 22,
                        :shadow_height => 20,
                        :image_url => "http://labs.google.com/ridefinder/images/mm_20_#{color}.png",
                        :shadow_url => "http://labs.google.com/ridefinder/images/mm_20_shadow.png",
                        :anchor_x => 6,
                        :anchor_y => 20,
                        :info_anchor_x => 5,
                        :info_anchor_y => 1,
                        :map => map)
    end
  end

end