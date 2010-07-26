ENV['RAILS_ENV'] = 'test'

require 'test/unit'
require 'rubygems'
require 'actionpack'
require 'action_view'
require 'lib/unbacked_dom_id'
require 'lib/google_map'
require 'lib/google_map/bounding_box'
require 'lib/google_map/clusterer'
require 'lib/google_map/geo_xml'
require 'lib/google_map/icon'
require 'lib/google_map/letter_icon'
require 'lib/google_map/map'
require 'lib/google_map/marker'
require 'lib/google_map/marker_group'
require 'lib/google_map/point'
require 'lib/google_map/polyline'
require 'lib/google_map/small_icon'

def marker_factory(options = {})
  params = {
    :map => @map, 
    :lat => 40, 
    :lng => -100, 
    :html => 'Test Marker'
  }.merge(options)
  GoogleMap::Marker.new(params)
end

def polyline_factory(options = {})
  params = {
    :map => @map, 
    :color => "#00FF00", 
    :weight => 10, 
    :opacity => 2, 
    :vertices => [
      GoogleMap::Point.new(40, -100),
      GoogleMap::Point.new(40, 100)]
  }.merge(options)
  GoogleMap::Polyline.new(params)
end

def geoxml_factory(options = {})
  params = {
    :url_of_xml => "http://code.google.com/apis/kml/documentation/KML_Samples.kml"
  }.merge(options)
  GoogleMap::GeoXml.new(params)
end



