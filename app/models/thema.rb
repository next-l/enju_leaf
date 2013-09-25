class Thema < ActiveRecord::Base
  
  acts_as_list
  default_scope :order => "position"
  attr_accessible :description, :name, :note, :position, :publish
  
  validates_presence_of :name, :position, :publish
  validates_uniqueness_of :name

  PUBLISH_PATTERN = {I18n.t('resource.publish') => 0, I18n.t('resource.closed') => 1}
  POSITION_PATTERN = {'0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4 }  
  

  # TODO: 以下のバリデーションを追加してください
  # name はユニークであること
  # name, display_name, position, publish が空白登録できないこと
  # TODO: manifestation_idと関連を作成後の作業
  # manifestation との関連の検証
end
