module EnjuCirculation
  module EnjuBasket
    extend ActiveSupport::Concern

    included do
      has_many :checked_items, dependent: :destroy
      has_many :items, through: :checked_items
      has_many :checkouts, dependent: :restrict_with_exception
      has_many :checkins, dependent: :restrict_with_exception
    end

    def basket_checkout(librarian)
      return nil if checked_items.size.zero?

      Item.transaction do
        checked_items.each do |checked_item|
          checkout = user.checkouts.new(
            librarian: librarian,
            item: checked_item.item,
            basket: self,
            library: librarian.profile.library,
            shelf: checked_item.item.shelf,
            due_date: checked_item.due_date
          )
          checkout.save!
          checked_item.item.checkout!(user)
        end
        CheckedItem.where(basket_id: id).destroy_all
      end
    end
  end
end
