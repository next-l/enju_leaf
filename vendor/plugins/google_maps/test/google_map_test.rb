require File.dirname(__FILE__) + '/test_helper'

GOOGLE_APPLICATION_ID = "ABQIAAAA3HdfrnxFAPWyY-aiJUxmqRTJQa0g3IQ9GZqIMmInSLzwtGDKaBQ0KYLwBEKSM7F9gCevcsIf6WPuIQ"

class GoogleMapTest < Test::Unit::TestCase
  def setup
    @map = GoogleMap::Map.new
  end

  def test_new_map_has_empty_markers
    assert @map.markers.empty?
  end

  def test_add_markers
    (1..5).each do |i|
      @map.markers << marker_factory
      assert_equal @map.markers.length, i
      puts @map.to_html
      assert @map.to_html.include? "google_map_marker_#{i} = new GMarker( new GLatLng( 40, -100 )  );"
    end
  end
  
  def test_center_on_markers_function_for_empty_map
    assert @map.center_map_js.include? "google_map.setCenter(google_map_latlng_bounds.getCenter(), google_map.getBoundsZoomLevel(google_map_latlng_bounds));"
  end

  def test_center_on_markers_function_for_one_marker
    @map.markers << marker_factory
    assert @map.center_map_js.include? "google_map_latlng_bounds.extend(new GLatLng(40, -100));"
  end

  def test_center_on_markers_function_for_two_markers
    @map.markers << marker_factory
    @map.markers << marker_factory({:lng => 100})
    assert @map.center_map_js.include? "google_map_latlng_bounds.extend(new GLatLng(40, 100));"
  end
  
  def test_set_center_with_options
    @map = GoogleMap::Map.new({:center => GoogleMap::Point.new(10, 10)})
    @map.markers << marker_factory
    assert @map.center_map_js.include? "new GLatLng(10, 10)"
  end

  def test_add_polylines
    (1..5).each do |i|
      @map.overlays << polyline_factory
      assert_equal @map.overlays.length, i
      assert @map.to_html.include? "#{@map.overlays[i - 1].dom_id} = new GPolyline(#{@map.overlays[i - 1].dom_id}_vertices, '#00FF00', 10, 2);"
    end
  end
  
  def test_add_geoxml
    (1..5).each do |i|
      @map.overlays << geoxml_factory
      assert_equal @map.overlays.length, i
      assert @map.to_html.include? "#{@map.overlays[i - 1].dom_id} = new GGeoXml('http://code.google.com/apis/kml/documentation/KML_Samples.kml')";
    end
  end
  
  def test_map_type
    assert !@map.to_html.include?("setMapType(GoogleMap)")
    @map.map_type = "foo"
    assert @map.to_html.include? "setMapType(foo)"
  end
end
