module CheckoutlistHelper
  def checkout_checkout_types(user)
    string = ''
    checkouts = user.checkouts.not_returned.group_by{|c| c.item.checkout_type_id if c.try(:item).try(:checkout_type_id)} rescue []
    CheckoutType.all.each do |checkout_type|
      num = checkouts[checkout_type.id].try(:size) || 0
      string << checkout_type.display_name.localize + ": #{num} "
    end
    string.html_safe
  end
end
