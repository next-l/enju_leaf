class CheckoutlistsController < ApplicationController
  before_filter :check_librarian
  load_and_authorize_resource

  def index
    @displist = []
    dispList = Struct.new(:display_name, :items)
    @circulation_status = @selected_circulation_status = CirculationStatus.order('position')
    @circulation_status.each do |c|
      items = Item.find(:all, :joins => [:manifestation, :circulation_status, :shelf => :library], 
        :conditions => {:circulation_status_id => c.id}, :order => 'libraries.id, items.shelf_id, items.item_identifier')
      @displist << dispList.new(c.display_name.localize, items)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @manifestations }
    end
  end

  def output
    @displist = []
    dispList = Struct.new(:display_name, :items)

    if params[:circulation_status].blank?
      # wrong checked
      @checked_nil = true
      @circulation_status = CirculationStatus.order('position')
      @circulation_status.each do |c|
        items = Item.find(:all, :joins => [:manifestation, :circulation_status, :shelf => :library], 
          :conditions => {:circulation_status_id => c.id}, :order => 'libraries.id, items.shelf_id, items.item_identifier')
        @displist << dispList.new(c.display_name.localize, items)
      end
      flash[:notice] = t('item_list.no_list_condition')
      render :index
      return
    end

    # output
    params[:circulation_status].each do |c|
      items = Item.find(:all, :joins => [:manifestation, :circulation_status, :shelf => :library], 
        :conditions => {:circulation_status_id => c}, :order => 'libraries.id, items.shelf_id, items.item_identifier')
      @displist << dispList.new(CirculationStatus.find(c).display_name.localize, items)
    end

    if params[:output_pdf]
      output_pdf
    elsif params[:output_tsv]
      output_tsv
    end
  end

  private
  def output_pdf
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'circulation_status_list.tlf')

    # set page_num
    report.events.on :page_create do |e|
      e.page.item(:page).value(e.page.no)
    end
    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:total).value(e.report.page_count)
      end
    end

    # set items
    report.start_new_page do |page|
      page.item(:date).value(Time.now)

      before_status = nil
      @displist.each do |d|
        unless d.items.blank?
          d.items.each do |item|
            page.list(:list).add_row do |row|
              if before_status == d.display_name
               row.item(:status_line).hide
               row.item(:status).hide
              end
              row.item(:status).value(d.display_name)
              row.item(:title).value(item.manifestation.original_title)
              row.item(:library).value(item.shelf.library.display_name)
              row.item(:shelf).value(item.shelf.display_name.localize)
              row.item(:call_number).value(item.call_number)
              row.item(:identifier).value(item.item_identifier)
            end
            before_status = d.display_name
          end
        else
          page.list(:list).add_row do |row|
            row.item(:status).value(d.display_name)
            row.item(:title).value(t('page.no_record_found'))
            row.item(:line2).hide
            row.item(:line3).hide
            row.item(:line4).hide
            row.item(:line5).hide
          end
        end
      end
    end
    send_data report.generate, :filename => configatron.checkoutlist_report_pdf.filename, :type => 'application/pdf', :disposition => 'attachment'
  end

  def output_tsv
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
        title = item.manifestation.original_title || ""
        library = item.shelf.library.display_name || "" 
        shelf = item.shelf.display_name.localize || "" 
        call_number = item.call_number || ""
        item_identifier = item.item_identifier || ""
	@buf << "\"" + title + "\"" + "\t" +
                "\"" + library + "\"" + "\t" +
                "\"" + shelf + "\"" + "\t" +
                "\"" + call_number + "\"" + "\t" +
                "\"" + item_identifier + "\"" + "\t" +
	        "\n"
      end
      @buf << "\n"
    end 
    send_data(@buf, :filename => configatron.checkoutlist_report_tsv.filename)
  end
end
