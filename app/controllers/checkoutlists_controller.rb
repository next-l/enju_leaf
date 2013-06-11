class CheckoutlistsController < ApplicationController
  before_filter :check_librarian
  load_and_authorize_resource

  def index
    @selected_circulation_ids = params[:circulation_status].map{|s| s.to_i} if params[:circulation_status]
    if params[:pdf] || params[:tsv]
      @displist = []
      if params[:circulation_status].blank?
        flash[:notice] = t('item_list.no_list_condition')
        return
      end
      send_data Checkoutlist.get_checkoutlist('pdf', @selected_circulation_ids).generate, :filename => Setting.checkoutlist_report_pdf.filename if params[:pdf]
      send_data Checkoutlist.get_checkoutlist('tsv', @selected_circulation_ids), :filename => Setting.checkoutlist_report_tsv.filename if params[:tsv]
    else
      @circulation_status = CirculationStatus.all
      @item_nums = Hash.new
      selected_circulation_ids = @selected_circulation_ids ||= @circulation_status.map(&:id)
      @circulation_status.each do |c|
        @item_nums[c.display_name.localize] = Item.count_by_sql(["select count(*) from items where circulation_status_id = ?", c.id])
      end
      search = Sunspot.new_search(Item) #.include([:shelf => :library])
      per_page = Item.default_per_page
      page = params[:page].try(:to_i) || 1
      set_role_query(current_user, search)
      search.build do
        with(:circulation_status_id).any_of selected_circulation_ids if selected_circulation_ids
        order_by(:circulation_status_id, :asc)
        paginate :page => page, :per_page => per_page
      end
      @items = search.execute.results
    end
  end
end

