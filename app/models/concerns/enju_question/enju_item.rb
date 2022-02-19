module EnjuQuestion
  module EnjuItem
    extend ActiveSupport::Concern

    included do
      has_many :answer_has_items, dependent: :destroy
      has_many :answers, through: :answer_has_items
    end
  end
end
