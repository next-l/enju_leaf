class ExportItemListsController < ApplicationController
  def index
    @list_types = [[t('item_list.shelf_list'),1],
                   [t('item_list.call_number_list'), 2],
                   [t('item_list.removed_list'), 3],
                   [t('item_list.unused_list'), 4],
                   [t('item_list.new_item_list'), 5]]
    @libraries = Library.all
    @carrier_types = CarrierType.all
  end
  def create
    list_type = params[:export_item_list][:list_type]
    library_ids = params[:library]
    carrier_type_ids = params[:carrier_type]
    case list_type.to_i
    when 1
      logger.error "SQL start at: #{Time.now}"
      @items = Item.find(:all, :joins => [:manifestation, :shelf => :library], :conditions => {:shelves => {:libraries => {:id => library_ids}}, :manifestations => {:carrier_type_id => carrier_type_ids}}, :order => 'libraries.id, shelves.id')
      logger.error "SQL end at: #{Time.now}"
      logger.error "found: #{@items.length} records"
    when 2
    when 3
    when 4
    else
    end
    begin
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/export_item_lists/item_list"

      report.events.on :page_create do |e|
        e.page.item(:page).value(e.page.no)
      end
      report.events.on :generate do |e|
        e.pages.each do |page|
          page.item(:total).value(e.report.page_count)
        end
      end
      
      report.start_new_page
      report.page.item(:date).value(Time.now)
      @items.each do |item|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(item.shelf.library.display_name.localize)
          row.item(:carrier_type).value(item.manifestation.carrier_type.display_name.localize)
          row.item(:shelf).value(item.shelf.display_name)
#          row.item(:ndc)
          row.item(:item_identifier).value(item.item_identifier)
          row.item(:title).value(item.manifestation.original_title)
        end
      end

      send_data report.generate, :filename => "item_list.pdf", :type => 'application/pdf', :disposition => 'attachment'
      logger.error "created report: #{Time.now}"
      return true
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end
end
