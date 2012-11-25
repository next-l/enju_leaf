#http://stackoverflow.com/questions/9107531/how-to-deal-with-vendor-plugins-after-upgrading-to-rails-3-2-1

$LOAD_PATH.unshift Rails.root.join('lib', 'enju_barcode', 'lib')
$LOAD_PATH.unshift Rails.root.join('lib', 'enju_barcode', 'app', 'controllers')
$LOAD_PATH.unshift Rails.root.join('lib', 'enju_barcode', 'app', 'models')
$LOAD_PATH.unshift Rails.root.join('lib', 'enju_barcode', 'app', 'views')

require 'enju_barcode.rb'
require 'barcode_sheet.rb'

#TODO
Dir[Rails.root.join('lib', 'enju_barcode', '**', '*.rb')].each do |file|
  require file
end

#puts $LOAD_PATH

=begin
Dir[Rails.root.join('lib', 'enju_barcode', '**', '*')].each do |plugin|
	puts plugin

	lib = File.join(plugin, 'lib')
	$LOAD_PATH.unshift lib

	begin
		require File.join(plugin, 'init.rb')
	rescue LoadError
		begin
			require File.join(lib, File.basename(plugin) + '.rb')
		rescue LoadError
			require File.join(lib, File.basename(plugin).underscore + '.rb')
		end
	end

	initializer = File.join(File.dirname(plugin), 'initializers', File.basename(plugin) + '.rb')
	require initializer if File.exists?(initializer)
end
=end
