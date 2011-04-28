class BasketSweeper < ActionController::Caching::Sweeper
  observe Basket
  include ExpireEditableFragment

  def after_save(record)
    record.checkouts.each do |checkout|
      expire_editable_fragment(checkout.item, ['detail'])
      expire_editable_fragment(checkout.item.manifestation, ['holding', 'show_list'], ['html', 'mobile'])
    end
  end

  def after_destroy(record)
    after_save(record)
  end
end
