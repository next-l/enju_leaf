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
      output_type = params[:pdf] ? 'pdf' : 'tsv'
      Checkoutlist.get_checkoutlist(output_type, current_user, @selected_circulation_ids) do |output|
        send_opts = {
          :filename => output.filename,
          :type => output.mime_type || 'application/octet-stream',
        }
        case output.result_type
        when :path
          send_file output.path, send_opts
        when :data
          send_data output.data, send_opts
        when :delayed
          flash[:message] = t('checkoutlist.output_job_queued', :job_name => output.job_name)
          redirect_to checkoutlists_path(:circulation_status => params[:circulation_status])
        else
          raise 'unknown result type (bug?)'
        end
      end
    end
    search = Sunspot.new_search(Item) #.include([:shelf => :library])
    per_page = Item.default_per_page
    page = params[:page].try(:to_i) || 1
    set_role_query(current_user, search)
    c_ids = @selected_circulation_ids
    search.build do 
      with(:circulation_status_id).any_of c_ids if c_ids
      order_by(:circulation_status_id, :asc)
      paginate :page => page, :per_page => per_page
    end
    @items = search.execute.results
    prepare_options
  end

  def prepare_options
    @circulation_status = CirculationStatus.all
    @item_nums = Hash.new
    @selected_circulation_ids ||= @circulation_status.map(&:id)
    @circulation_status.each do |c|
      @item_nums[c.display_name.localize] = Item.count_by_sql(["select count(*) from items where circulation_status_id = ?", c.id])
    end
    params[:pdf], params[:tsv] = nil, nil
  end 

end

