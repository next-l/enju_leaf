class AddLocaleToMessageTemplate < ActiveRecord::Migration
  def self.up
    add_column :message_templates, :locale, :string, :default => I18n.default_locale.to_s
  end

  def self.down
    remove_column :message_templates, :locale
  end
end
