# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# Change the following
username = 'admin'
email = 'admin@example.jp'
password = 'adminpassword'

# Don't edit!
require 'active_record/fixtures'

unless solr = Sunspot.commit rescue nil
  raise "Solr is not running."
end

Dir.glob(Rails.root.to_s + '/db/fixtures/*.yml').each do |file|
  ActiveRecord::Fixtures.create_fixtures('db/fixtures', File.basename(file, '.*'))
end

Patron.reindex
Library.reindex

user = User.new
user.username = username
user.email = email
user.password = password
user.password_confirmation = password
user.library = Library.real.first
user.patron = Patron.first
user.locale = I18n.default_locale.to_s
user.role = Role.find_by_name('Administrator')
user.user_number = '0'
user.operator = user
user.save!
#user.confirm!
user.index!
puts 'Administrator account created.'

# sample
user = User.new
user.username = "librarian1"
user.password = "enjuenju"
user.password_confirmation = "enjuenju"
user.library = Library.real.first
user.patron = Patron.find(2)
user.locale = I18n.default_locale.to_s
user.role =  Role.find_by_name('Librarian')
user.operator = user
user.save!

user = User.new
user.username = "librarian2"
user.password = "enjuenju"
user.password_confirmation = "enjuenju"
user.library = Library.find(3)
user.patron = Patron.find(3)
user.locale = I18n.default_locale.to_s
user.role =  Role.find_by_name('Librarian')
user.operator = user
user.save!

user = User.new
user.username = "librarian3"
user.password = "enjuenju"
user.password_confirmation = "enjuenju"
user.library = Library.find(4)
user.patron = Patron.find(4)
user.locale = I18n.default_locale.to_s
user.role =  Role.find_by_name('Librarian')
user.operator = user
user.save!

user = User.new
user.username = "librarian4"
user.password = "enjuenju"
user.password_confirmation = "enjuenju"
user.library = Library.find(5)
user.patron = Patron.find(5)
user.locale = I18n.default_locale.to_s
user.role =  Role.find_by_name('Librarian')
user.operator = user
user.save!

puts 'demo account created.'
