# -*- encoding: utf-8 -*-
class AddTypeId96ToSystemConfiguration < ActiveRecord::Migration
  def change
  end

  s = SystemConfiguration.find_or_initialize_by_keyname("manifestation.has_one_item")
  s.update_attributes(
    :v => "false",
    :typename => "Boolean",
    :description => "書誌と所蔵を１：１で管理する",
    :category => "manifestation"
  )

end
