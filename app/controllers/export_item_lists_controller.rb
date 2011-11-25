class ExportItemListsController < ApplicationController
  def index
    prepare_options
  end

  def create
    list_type = params[:export_item_list][:list_type]
    library_ids = params[:library]
    carrier_type_ids = params[:carrier_type]

    ndc_str = params[:ndc]
    unless ndc_str.blank? 
      ndcs = ndc_str.gsub(' ', '').split(",") 
      ndcs.each do |ndc|
        unless ndc =~ /^\d{3}$/
          logger.error ndc
          flash[:message] = t('item_list.invalid_ndc')
          @ndc = ndc_str
          prepare_options
          render :index
          return false
        end
      end
    end

    logger.error "SQL start at #{Time.now}"
    case list_type.to_i
    when 1
      query = ""
      ndcs.each {|ndc| query += "manifestations.ndc LIKE '#{ndc}%' OR "} if ndcs
      query.gsub!(/OR\s$/, "AND ")
      query += "libraries.id IN (#{library_ids.join(',')}) AND manifestations.carrier_type_id IN (#{carrier_type_ids.join(',')})"
      @items = Item.find(:all, :joins => [:manifestation, :shelf => :library], :conditions => query, :order => 'libraries.id, manifestations.carrier_type_id, shelves.id, manifestations.ndc')
      filename = t('item_list.shelf_list')
    when 2
      @items = Item.find(:all, :joins => [:manifestation, :shelf => :library], :conditions => {:shelves => {:libraries => {:id => library_ids}}, :manifestations => {:carrier_type_id => carrier_type_ids}}, :order => 'items.call_number')
      filename = t('item_list.call_number_list')
    when 3
      @items = Item.find(:all, :joins => [:manifestation, :circulation_status, :shelf => :library], :conditions => {:shelves => {:libraries => {:id => library_ids}}, :manifestations => {:carrier_type_id => carrier_type_ids}, :items => {:circulation_statuses => {:name => "Removed"}}}, :order => 'libraries.id, manifestations.carrier_type_id, items.shelf_id, items.item_identifier, manifestations.original_title')
      filename = t('item_list.removed_list')
    when 4
      checkouts = Checkout.select(:item_id).map(&:item_id).uniq!
      @items = Item.find(:all, :joins => [:manifestation, :shelf => :library], :conditions => {:shelves => {:libraries => {:id => library_ids}}, :manifestations => {:carrier_type_id => carrier_type_ids}}, :order => 'libraries.id, manifestations.carrier_type_id, items.shelf_id, items.item_identifier')
      @items.delete_if{|item|checkouts.include?(item.id)}
      filename = t('item_list.unused_list')
    when 5
      query = ""
      ndcs.each {|ndc| query += "manifestations.ndc LIKE '#{ndc}%' OR "} if ndcs
      query.gsub!(/OR\s$/, "AND ")
      query += "libraries.id IN (#{library_ids.join(',')}) AND manifestations.carrier_type_id IN (#{carrier_type_ids.join(',')})"
      @items = Item.recent.find(:all, :joins => [:manifestation, :shelf => :library], :conditions => query, :order => 'libraries.id, manifestations.carrier_type_id, items.shelf_id, items.item_identifier, manifestations.original_title')
      filename = t('item_list.new_item_list')
    end
    logger.error "SQL end at #{Time.now}\nfound #{@items.length rescue 0} records"

    if @items.blank?
      flash[:message] = t('item_list.no_record')
      @ndc = ndc_str
      prepare_options
      render :index
      return false
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
      report.page.item(:list_name).value(filename)
      @items.each do |item|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(item.shelf.library.display_name.localize) if item.shelf && item.shelf.library
          row.item(:carrier_type).value(item.manifestation.carrier_type.display_name.localize) if item.manifestation && item.manifestation.carrier_type
          row.item(:shelf).value(item.shelf.display_name) if item.shelf
          row.item(:ndc).value(item.manifestation.ndc) if item.manifestation
          row.item(:item_identifier).value(item.item_identifier)
          row.item(:call_number).value(item.call_number)
          row.item(:title).value(item.manifestation.original_title) if item.manifestation
        end
      end

      send_data report.generate, :filename => "#{filename}.pdf", :type => 'application/pdf', :disposition => 'attachment'
      logger.error "created report: #{Time.now}"
      return true
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def prepare_options
    @list_types = [[t('item_list.shelf_list'),1],
                   [t('item_list.call_number_list'), 2],
                   [t('item_list.removed_list'), 3],
                   [t('item_list.unused_list'), 4],
                   [t('item_list.new_item_list'), 5]]
    @libraries = Library.all
    @carrier_types = CarrierType.all
  end
end
