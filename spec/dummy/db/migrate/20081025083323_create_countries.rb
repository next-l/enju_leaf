class CreateCountries < ActiveRecord::Migration[5.1]

  # ISO 3166 is the International Standard for country codes.
  #
  # ISO 3166-1:2006 Codes for the representation of names of countries and their subdivisions - Part 1: 
  # Country codes which is what most users know as ISO's country codes. First published in 1974, it is has since 
  # then become one of the world's most popular and most widely used standard solution for coding country names. 
  # It contains a two-letter code which is recommended as the general purpose code, a three-letter code which has 
  # better mnenomic properties and a numeric-3 code which can be useful if script independence of the codes is important.
  #
  # http://www.iso.org/iso/country_codes/background_on_iso_3166/what_is_iso_3166.htm

  def change
    create_table :countries do |t|
      t.string :name,         :size => 80, :null => false
      t.text :display_name
      t.string :alpha_2,      :size => 2
      t.string :alpha_3,      :size => 3
      t.string :numeric_3, :size => 3
      t.text :note
      t.integer :position
    end
    add_index :countries, :name
    add_index :countries, :alpha_2
    add_index :countries, :alpha_3
    add_index :countries, :numeric_3
  end
end
