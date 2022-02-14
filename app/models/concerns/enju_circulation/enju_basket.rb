module EnjuCirculation
  module EnjuBasket
    extend ActiveSupport::Concern

    included do
      has_many :checked_items, dependent: :destroy
      has_many :items, through: :checked_items
      has_many :checkouts
      has_many :checkins
    end

    def basket_checkout(librarian)
      return nil if checked_items.size.zero?

      Item.transaction do
        checked_items.each do |checked_item|
          checkout = user.checkouts.new
          checkout.librarian = librarian
          checkout.item = checked_item.item
          checkout.basket = self
          checkout.library = librarian.profile.library
          checkout.shelf = checked_item.item.shelf
          checkout.due_date = checked_item.due_date
          checked_item.item.checkout!(user)
          checkout.save!
        end
        CheckedItem.where(basket_id: id).destroy_all
      end
    end
  end
end
