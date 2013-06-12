# encoding: utf-8
class AddDataToSystemConfiguration < ActiveRecord::Migration
  def change
    system_configuration = SystemConfiguration.where(:keyname => 'exclude_patrons').first
    unless system_configuration
      SystemConfiguration.create(
        :keyname => 'exclude_patrons',
        :v => '他,ほか,et-al.',
        :typename => 'String',
        :description => '著者、協力者・編者、協力者・編者で指定時に人物・団体として扱わないワード',
        :category => 'manifestation'
      )
    end
  end
end
