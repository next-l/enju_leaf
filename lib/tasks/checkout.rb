def update_checkout
  Checkout.find_each do |checkout|
    checkout.update_column(:shelf_id, checkout.item.try(:shelf_id)) if checkout.shelf_id.nil?
    checkout.update_column(:library_id, checkout.librarian.try(:profile).try(:library_id)) if checkout.library_id.nil?

  end
end
