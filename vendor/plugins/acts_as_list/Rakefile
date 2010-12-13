require 'rake'
require 'rake/testtask'

desc 'Default: run acts_as_list unit tests.'
task :default => :test

desc 'Test the acts_as_ordered_tree plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "acts_as_list"
    gem.summary = %Q{This acts_as extension provides the capabilities for sorting and reordering a number of objects in a list. The class that has this specified needs to have a +position+ column defined as an integer on the mapped database table.}
    gem.description = %Q{This acts_as extension provides the capabilities for sorting and reordering a number of objects in a list. The class that has this specified needs to have a +position+ column defined as an integer on the mapped database table.}
    gem.email = "uher.mario@gmail.com"
    gem.homepage = "http://github.com/haihappen/acts_as_list"
    gem.authors = ["Mario Uher", "David Heinemeier Hansson"]
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end