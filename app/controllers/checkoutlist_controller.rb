class CheckoutlistController < ApplicationController
  #before_filter :store_location, :only => :index
  #load_and_authorize_resource
  #before_filter :get_user_if_nil, :only => :index
  #before_filter :get_user, :except => :index
  #helper_method :get_item
  #after_filter :convert_charset, :only => :index

  
  def index
    @title = t('page.statistics_exstats')

    @displist = []
    @DispList = Struct.new(:cirid, :dispname, :buflist)

    @cir = CirculationStatus.find(:all, :select=>'id, position, display_name', 
				  :order => 'position')

    @cir.each_with_index do |c, i|
      @displist << @DispList.new(c.id, dispname_change(c.display_name), [])

      @items = Item.find_by_sql(["SELECT original_title, call_number, item_identifier, shelves.display_name as shelf_name, libraries.display_name as libarary_name FROM items, shelves, libraries, manifestations, exemplifies WHERE circulation_status_id = ? AND libraries.id = shelves.library_id AND items.shelf_id = shelves.id AND (items.id = exemplifies.id AND exemplifies.manifestation_id = manifestations.id)", c.id])

      next if @items.empty?

      @items.each_with_index do |d, j|
        @displist[i].buflist[j] = {}
	if d.call_number.nil?
          @displist[i].buflist[j]['call_number'] = " "
	else
          @displist[i].buflist[j]['call_number'] = d.call_number
	end

	if d.item_identifier.nil?
          @displist[i].buflist[j]['item_identifier'] = " "
	else
          @displist[i].buflist[j]['item_identifier'] = d.item_identifier
	end

	if d['original_title'].nil?
          @displist[i].buflist[j]['original_title'] = " "
	else
          @displist[i].buflist[j]['original_title'] = d['original_title']
	end

	if d['shelf_name'].nil?
          @displist[i].buflist[j]['shelf_name'] = " "
	else
          @displist[i].buflist[j]['shelf_name'] = d['shelf_name']
	end

	if d['libarary_name'].nil?
          @displist[i].buflist[j]['libarary_name'] = " "
	else
          @displist[i].buflist[j]['libarary_name'] = d['libarary_name']
	end
      end
    end

    if params[:commit]
      download("checkoutlist.tsv")
      return
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @manifestations }
    end
  end

  def download(fname)
    @buf = String.new
    @displist.each_with_index do |d, i|
      @buf << "\"" + d.dispname + "\"" + "\n" 
      @buf << "\"" + t('activerecord.attributes.manifestation.original_title') + "\"" + "\t" +
	"\"" + t('activerecord.models.library') + "\"" + "\t" +
	"\"" + t('activerecord.models.shelf') + "\"" + "\t" +
	"\"" + t('activerecord.attributes.item.call_number') + "\"" + "\t" +
	"\"" + t('activerecord.attributes.item.item_identifier') + "\"" + "\t" +
        "\n"
 
      d.buflist.each do |b|
	@buf << "\"" + b["original_title"] + "\"" + "\t" +
                "\"" + b["libarary_name"] + "\"" + "\t" +
                "\"" + b["shelf_name"] + "\"" + "\t" +
                "\"" + b["call_number"] + "\"" + "\t" +
                "\"" + b["item_identifier"] + "\"" + "\t" +
	        "\n"
      end
      @buf << "\n"
    end 
    send_data(@buf, :filename => fname)
  end

  def dispname_change(dispstr)
    @idx = dispstr.index("ja:")
    if @idx == nil || @idx == 0
      return dispstr
    else
      return dispstr[@idx + 3..@idx + 3 + dispstr.split(//u).length]
    end
  end

end
