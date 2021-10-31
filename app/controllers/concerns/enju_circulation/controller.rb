module EnjuCirculation
  module Controller
    extend ActiveSupport::Concern

    def get_checkout_type
      if params[:checkout_type_id]
        @checkout_type = CheckoutType.find(params[:checkout_type_id])
        authorize @checkout_type, :show?
      end
    end
  end
end
