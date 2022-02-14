module MasterModel
  extend ActiveSupport::Concern

  included do
    acts_as_list
    validates :name, uniqueness: { case_sensitive: false }
    validates :name, presence: true
    validate :name do
      valid_name?
    end
    validate :display_name do
      valid_yaml?
    end
    validates :display_name, presence: true
    before_validation :set_display_name, on: :create
    strip_attributes only: :name
  end

  # 表示名を設定します。
  def set_display_name
    self.display_name = "#{I18n.locale}: #{name}" if display_name.blank?
  end

  private
  def valid_name?
    unless name =~ /\A[a-z][0-9a-z_]*[0-9a-z]\z/
      errors.add(:name, I18n.t('page.only_lowercase_letters_and_numbers_are_allowed'))
    end
  end

  def valid_yaml?
    begin
      YAML.load(display_name)
    rescue Psych::SyntaxError
      errors.add(:display_name, I18n.t('page.cannot_parse_yaml_header'))
    end
  end
end
