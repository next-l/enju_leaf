module EnjuPurchaseRequest
  module EnjuUser
    extend ActiveSupport::Concern

    included do
      has_many :purchase_requests
      has_many :order_lists
    end
  end
end
