# http://railspress.matake.jp/extend-plugin-gem-library-in-rails-project
require File.expand_path(File.join(File.dirname(__FILE__), 'plugins', 'ext'))

require 'enju_trunk_circulation' rescue nil
begin
  require 'enju_trunk_ill' 
rescue LoadError
  puts "info: enju_trunk_ill error"
end
begin
  require 'enju_trunk_statistics' 
rescue LoadError
  puts "info: enju_trunk_statistics"
end
 
