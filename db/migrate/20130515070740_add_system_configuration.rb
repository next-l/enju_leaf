# -*- encoding: utf-8 -*-
class AddSystemConfiguration < ActiveRecord::Migration
  def up
    unless SystemConfiguration.find_by_id(98)
      SystemConfiguration.create(:id => 98, :keyname => 'offline_client_crypt_password',
                                 :v => "", :typename => 'String', :description => "オフラインクライアント暗号化パスワード",
                                 :category => 'general')
    end
    unless SystemConfiguration.find_by_id(99)
      SystemConfiguration.create(:id => 99, :keyname => 'user_change_department',
                                 :v => "false", :typename => 'Boolean', :description => "自分自身で利用者の部課の変更が出来るか？",
                                 :category => 'user')
    end
  end

  def down
    SystemConfiguration.delete(98)
    SystemConfiguration.delete(99)
  end
end
