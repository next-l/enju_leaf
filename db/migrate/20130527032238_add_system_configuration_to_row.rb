# -*- encoding: utf-8 -*-
class AddSystemConfigurationToRow < ActiveRecord::Migration
  def up
    system_configuration = SystemConfiguration.where(:keyname => 'use_copy_request').first
    unless system_configuration
      SystemConfiguration.create(
        :keyname => 'use_copy_request',
        :v => 'false',
        :typename => 'Boolean',
        :description => '文献複写依頼を使用するか',
        :category => 'copy_request'
      )
    end 
  end

  def down
    SystemConfiguration.where(:keyname => 'use_copy_request').first.destroy
  end
end
