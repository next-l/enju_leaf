class Thema < ActiveRecord::Base
  attr_accessible :description, :desplay_name, :name, :note, :position, :publish

  # TODO: 以下のバリデーションを追加してください
  # name はユニークであること
  # name, display_name, position, publish が空白登録できないこと
  # TODO: manifestation_idと関連を作成後の作業
  # manifestation との関連の検証
end
