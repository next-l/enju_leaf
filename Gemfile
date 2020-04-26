source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in enju_leaf.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.
gem 'jquery-rails'
gem 'sprockets', '~> 3.7'

# To use debugger
# gem 'debugger'
group :test do
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter'
end

gem 'enju_biblio', github: 'next-l/enju_biblio', branch: '1.3'
