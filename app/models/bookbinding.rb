class Bookbinding < ActiveRecord::Base
   has_many :binding_items
   has_many :items, :through => :binding_items
   
   def book_binding
    Item.transaction do
      if self.binding_items.blank?
         errors[:base] = I18n.t('activerecord.errors.messages.bookbinding.bookbinding_nil')
         return nil
      else
         binder = Item.new()
         binder.bookbinder = true
         new_manifestation = Manifestation.new()
         new_manifestation.original_title = binding_items[0].item.manifestation.original_title
         new_manifestation.bookbinder = true
         new_manifestation.save!
         binder.manifestation = new_manifestation
         binder.circulation_status = CirculationStatus.where(:name => 'In Factory').first
         binder.shelf = Shelf.where(:name => 'binding_shelf').first rescue nil
         binder.save!
         self.binding_items.each do |binding_item|
          binding_item.item.bookbinder_id = binder.id
          binding_item.item.circulation_status = CirculationStatus.where(:name => 'Binded').first
          binding_item.item.shelf_id = binder.shelf_id
          binding_item.item.save!
          Manifestation.find(binding_item.item.manifestation.id).index
        end
        BindingItem.destroy_all(:bookbinding_id => self.id)
        return binder
      end
    end
  end

end
