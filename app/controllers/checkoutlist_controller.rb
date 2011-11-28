class CheckoutlistController < ApplicationController
  #before_filter :store_location, :only => :index
  #load_and_authorize_resource
  #before_filter :get_user_if_nil, :only => :index
  #before_filter :get_user, :except => :index
  #helper_method :get_item
  #after_filter :convert_charset, :only => :index
  
  def index
    return access_denied unless (user_signed_in? and current_user.has_role?('Librarian'))

    prepare_options
    if params[:commit] == t('page.download')
      download("checkoutlist.tsv")
      return
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @manifestations }
    end
  end

  def output
    return access_denied unless (user_signed_in? and current_user.has_role?('Librarian')) 

    unless params[:all_circulation_status].blank?
      @circulation_status = CirculationStatus.order('position')
    else
      if params[:all_circulation_status].blank? and !params[:circulation_status].blank?
        @circulation_status = CirculationStatus.where(:id => params[:circulation_status]).order('position')
      else
        flash[:notice] = t('item_list.no_list_condition')
        prepare_options
        render :index
        return
      end
    end
    return if @circulation_status.nil?

    require 'thinreports'
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'circulation_status_list.tlf')

    report.events.on :page_create do |e|
      e.page.item(:page).value(e.page.no)
    end
    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:total).value(e.report.page_count)
      end
    end

    report.start_new_page do |page|
      page.item(:date).value(Time.now)

      before_status = nil
      @circulation_status.each do |c|
        @items = Item.find(:all, :joins => [:manifestation, :circulation_status, :shelf => :library], 
          :conditions => {:circulation_status_id => c.id}, :order => 'libraries.id, items.shelf_id, items.item_identifier')
        unless @items.blank?
          @items.each do |item|
            page.list(:list).add_row do |row|
              if before_status == c
               row.item(:status_line).hide
               row.item(:status).hide
              end
              row.item(:status).value(c.display_name.localize)
              row.item(:title).value(item.manifestation.original_title)
              row.item(:library).value(item.shelf.library.display_name)
              row.item(:shelf).value(item.shelf.display_name.localize)
              row.item(:call_number).value(item.call_number)
              row.item(:identifier).value(item.item_identifier)
            end
            before_status = c
          end
        else
          page.list(:list).add_row do |row|
            row.item(:status).value(c.display_name.localize)
            row.item(:title).value(t('page.no_record_found'))
            row.item(:line2).hide
            row.item(:line3).hide
            row.item(:line4).hide
            row.item(:line5).hide
          end
        end
      end
    end
    send_data report.generate, :filename => configatron.checkoutlist_report.filename, :type => 'application/pdf', :disposition => 'attachment'
  end

  private
  def prepare_options
    @displist = []
    @DispList = Struct.new(:display_name, :items)
    @circulation_status = CirculationStatus.order('position')
    @circulation_status.each_with_index do |c, i|
      @items = Item.find(:all, :joins => [:manifestation, :circulation_status, :shelf => :library], 
        :conditions => {:circulation_status_id => c.id}, :order => 'libraries.id, items.shelf_id, items.item_identifier')
      items = Item.find(:all, :joins => [:manifestation, :circulation_status, :shelf => :library], 
        :conditions => {:circulation_status_id => c.id}, :order => 'libraries.id, items.shelf_id, items.item_identifier')
      @displist << @DispList.new(c.display_name.localize, items)
    end

  end

  def download(fname)
    @buf = String.new
    @displist.each_with_index do |d, i|
      @buf << "\"" + d.display_name + "\"" + "\n" 
      @buf << "\"" + t('activerecord.attributes.manifestation.original_title') + "\"" + "\t" +
	"\"" + t('activerecord.models.library') + "\"" + "\t" +
	"\"" + t('activerecord.models.shelf') + "\"" + "\t" +
	"\"" + t('activerecord.attributes.item.call_number') + "\"" + "\t" +
	"\"" + t('activerecord.attributes.item.item_identifier') + "\"" + "\t" +
        "\n"
 
      d.items.each do |item|
	if item.manifestation.original_title.blank?
          title = ""
        else
          title = item.manifestation.original_title
        end
        if item.shelf.library.display_name.blank?
          library = ""
        else
          library = item.shelf.library.display_name 
        end
        if item.shelf.display_name.blank?
          shelf = ""
        else
          shelf = item.shelf.display_name.localize 
        end
        if item.call_number.blank? 
          call_number = ""
        else
          call_number = item.call_number
        end
        if item.item_identifier.blank?
          item_identifier = ""
        else
          item_identifier = item.item_identifier
        end
	@buf << "\"" + title + "\"" + "\t" +
                "\"" + library + "\"" + "\t" +
                "\"" + shelf + "\"" + "\t" +
                "\"" + call_number + "\"" + "\t" +
                "\"" + item_identifier + "\"" + "\t" +
	        "\n"
      end
      @buf << "\n"
    end 
    send_data(@buf, :filename => fname)
  end
end
