module Calil
  class Barcode
    include ActiveModel::Model
    include ActiveModel::Attributes
    attributes :name, :string
    attributes :initial_number, :string
    attribuets :number_of_sheets, :integer, default: 1

    with_options presence: true do
      validates :name # 図書館名
      validates :initial_number # 開始番号
    end
    validates :number_of_sheets, numericality: { greater_than_or_equal_to: 0 } # 枚数
  end
end
