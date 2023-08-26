module Calil
  class Barcode
    include ActiveModel::Model
    attr_accessor :name, :initial_number, :number_of_sheets

    with_options presence: true do
      validates :name # 図書館名
      validates :initial_number # 開始番号
    end
    validates :number_of_sheets, numericality: { greater_than_or_equal_to: 0 } # 枚数
  end
end
