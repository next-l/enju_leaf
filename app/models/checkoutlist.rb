class Checkoutlist < ActiveRecord::Base
  paginates_per 10

  def self.get_checkoutlist(type, circulation_status_ids)
    dispList = Struct.new(:circulation_status, :items)
    @displist = []
    circulation_status_ids.each do |c|
      items = Item.find(:all, :joins => [:manifestation, :circulation_status, :shelf => :library], :conditions => { :circulation_status_id => c }, :order => 'libraries.id, items.shelf_id, items.item_identifier')
      @displist << dispList.new(CirculationStatus.find(c).display_name.localize, items)
    end
    data = Checkout.get_checkoutlists_pdf(@displist) if type == 'pdf'
    data = Checkout.get_checkoutlists_tsv(@displist) if type == 'tsv'
    return data
  end
end
