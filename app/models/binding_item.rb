class BindingItem < ActiveRecord::Base
   belongs_to :item
   belongs_to :bookbinding
   attr_accessor :item_identifier
   attr_accessible :item_identifier
   validates_uniqueness_of :item_id, :scope => :bookbinding_id

   def validate
      unless item
         errors[:base] << I18n.t("activerecord.errors.messages.binding_item.not_exist")
      else
         unless item.bookbinder_id.nil?
            errors[:base] << I18n.t("activerecord.errors.messages.binding_item.binded")
         end
         binding_items = BindingItem.find(:first, :conditions => ["bookbinding_id=?", bookbinding_id])
         unless binding_items.nil?
             unless BindingItem.find(:all, :conditions => ["item_id=?", item_id]).blank?
                 errors[:base] << I18n.t("activerecord.errors.messages.binding_item.in_transation")
             end
             unless item.manifestation.series_statement_id == binding_items.item.manifestation.series_statement_id
                 errors[:base] << I18n.t("activerecord.errors.messages.binding_item.not_same_series")
             end
         end
      end
   end
end
