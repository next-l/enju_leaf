# -*- encoding: utf-8 -*-
class AddTypeId97ToSystemConfiguration < ActiveRecord::Migration
  def change
  end

  s = SystemConfiguration.find_or_initialize_by_keyname("manifestation.isbn_unique")
  s.update_attributes(
    :v => "true",
    :typename => "Boolean",
    :description => "ISBNは重複しない",
    :category => "manifestation"
  )

end
