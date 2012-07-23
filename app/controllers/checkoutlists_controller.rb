class CheckoutlistsController < ApplicationController
  before_filter :check_librarian
  load_and_authorize_resource

  def index
    @displist = []
    dispList = Struct.new(:circulation_status, :items)
    @circulation_status = CirculationStatus.all

    if params[:format] == 'pdf' or params[:format] == 'tsv'
      @selected_circulation_status = params[:circulation_status] || []
      if params[:circulation_status].blank?
        @circulation_status.each do |c|
          items = Item.find(:all, :joins => [:manifestation, :circulation_status, :shelf => :library], :conditions => { :circulation_status_id => c }, :order => 'libraries.id, items.shelf_id, items.item_identifier')
          @displist << dispList.new(CirculationStatus.find(c).display_name.localize, items)
        end
        flash[:notice] = t('item_list.no_list_condition')
        render :index, :formats => 'html'; return
      end
    else
      @selected_circulation_status = @circulation_status.map{ |c| c.id }
    end
    @selected_circulation_status.each do |c|
      items = Item.find(:all, :joins => [:manifestation, :circulation_status, :shelf => :library], :conditions => { :circulation_status_id => c }, :order => 'libraries.id, items.shelf_id, items.item_identifier')
      @displist << dispList.new(CirculationStatus.find(c).display_name.localize, items)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.pdf { send_data Checkout.get_checkoutlists_pdf(@displist).generate, :filename => configatron.checkoutlist_report_pdf.filename }
      format.tsv { send_data Checkout.get_checkoutlists_tsv(@displist), :filename => configatron.checkoutlist_report_tsv.filename }
    end
  end
end
