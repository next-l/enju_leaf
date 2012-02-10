class ExportItemListsController < ApplicationController
  before_filter :check_librarian

  def initialize
    @list_types = [[t('item_list.shelf_list'),1],
                   [t('item_list.call_number_list'), 2],
                   [t('item_list.removed_list'), 3],
                   [t('item_list.unused_list'), 4],
                   [t('item_list.new_item_list'), 5],
                   [t('item_list.latest_list'), 6]
                 ]
    @libraries = Library.all
    @carrier_types = CarrierType.all
    super
  end

  def index
    @selected_list_type = 1
    @selected_library = []
    @selected_carrier_type = [] 
    @libraries.each { |lib| @selected_library << lib.id }
    @carrier_types.each { |car| @selected_carrier_type << car.id }
    @items_size = Item.count(:all, :joins => [:manifestation, :shelf => :library])
    @page = (@items_size / 36).to_f.ceil
  end

  def create
    flash[:message] = ""

    # check checked
    @selected_list_type = params[:export_item_list][:list_type] || 1
    @selected_library = params[:library] || []
    @selected_carrier_type = params[:carrier_type] || []
    flash[:message] << t('item_list.no_list_condition') + '<br />' if @selected_library.blank? || @selected_carrier_type.blank?

    # check ndc
    @ndc = params[:ndc]
    unless @ndc.blank? 
      ndcs = @ndc.gsub(' ', '').split(",") 
      ndcs.each do |ndc|
        unless ndc =~ /^\d{3}$/
          logger.error ndc
          flash[:message] << t('item_list.invalid_ndc')
          break
        end
      end
    end

    unless flash[:message].blank?
      @items_size = 0
      @page = 0
      render :index; return false
    else
      list_type = params[:export_item_list][:list_type]
      file_type = params[:export_item_list][:file_type]

      logger.error "SQL start at #{Time.now}"
      case list_type.to_i
      when 1
        query = get_query(ndcs, @selected_library, @selected_carrier_type)
        @items = Item.find(:all, 
          :joins => [:manifestation, :shelf => :library], 
          :conditions => query, 
          :order => 'libraries.id, manifestations.carrier_type_id, shelves.id, manifestations.ndc')
        filename = t('item_list.shelf_list')
      when 2
        @items = Item.find(:all, 
          :joins => [:manifestation, :shelf => :library], 
          :conditions => {:shelves => {:libraries => {:id => @selected_library}}, 
          :manifestations => {:carrier_type_id => @selected_carrier_type}}, 
          :order => 'items.call_number')
        filename = t('item_list.call_number_list')
      when 3
        @items = Item.find(:all, 
          :joins => [:manifestation, :circulation_status, :shelf => :library], 
          :conditions => {:shelves => {:libraries => {:id => @selected_library}}, 
          :manifestations => {:carrier_type_id => @selected_carrier_type}, 
          :items => {:circulation_statuses => {:name => "Removed"}}}, 
          :order => 'libraries.id, manifestations.carrier_type_id, items.shelf_id, items.item_identifier, manifestations.original_title')
        filename = t('item_list.removed_list')
      when 4
        checkouts = Checkout.select(:item_id).map(&:item_id).uniq!
        @items = Item.find(:all, 
          :joins => [:manifestation, :shelf => :library], 
          :conditions => {:shelves => {:libraries => {:id => @selected_library}}, 
          :manifestations => {:carrier_type_id => @selected_carrier_type}}, 
          :order => 'libraries.id, manifestations.carrier_type_id, items.shelf_id, items.item_identifier')
        @items.delete_if{|item|checkouts.include?(item.id)}
        filename = t('item_list.unused_list')
      when 5
        query = get_query(ndcs, @selected_library, @selected_carrier_type)
        @items = Item.recent.find(:all, 
          :joins => [:manifestation, :shelf => :library], 
          :conditions => query, 
          :order => 'libraries.id, manifestations.carrier_type_id, items.shelf_id, items.item_identifier, manifestations.original_title')
        filename = t('item_list.new_item_list')
      when 6
        @items = []
        manifestations = SeriesStatement.latest_issues
        manifestations.each do |manifestation|
          manifestation.items.each do |item|
            @items << item if libraries.include?(item.shelf.library.id.to_s) rescue next
          end
        end
        filename = t('item_list.latest_list')
      end
      logger.error "SQL end at #{Time.now}\nfound #{@items.length rescue 0} records"

      begin
        if file_type == 'pdf'
          data = Item.make_export_item_list_pdf(@items, filename)
          unless data
            flash[:message] = t('item_list.no_record')
            @items_size = 0
            @page = 0
            render :index
            return false
          end
          send_data data.generate, :filename => "#{filename}.pdf"
        elsif file_type == 'tsv'
          data = Item.make_export_item_list_tsv(@items)
          send_data data, :filename => "#{filename}.tsv"
        end
        return true
      rescue Exception => e
        logger.error "failed #{e}"
        return false
      end
    end
  end

  def get_list_size
    return nil unless request.xhr?
    unless params[:list_type].blank?
      list_type = params[:list_type]
      ndcs = params[:ndc]
      libraries = params[:libraries]
      carrier_types = params[:carrier_types]
      error = false
      list_size = 0

      # check checkbox
      error = true if libraries.blank? || carrier_types.blank?

      # check ndc
      unless ndcs.blank?
        ndcs = ndcs.gsub(' ', '').split(",")
        ndcs.each do |ndc|
          unless ndc =~ /^\d{3}$/
            error = true
            break
          end
        end
      end

      # list_size
      unless error
        begin
          case list_type.to_i
          when 1
            query = get_query(ndcs, libraries, carrier_types)
            list_size = Item.count(:all, 
              :joins => [:manifestation, :shelf => :library], 
              :conditions => query)
          when 2
            list_size = Item.count(:all, 
              :joins => [:manifestation, :shelf => :library], 
              :conditions => {:shelves => {:libraries => {:id => libraries}}, :manifestations => {:carrier_type_id => carrier_types}})
          when 3
            list_size = Item.count(:all, 
              :joins => [:manifestation, :circulation_status, :shelf => :library], 
              :conditions => {:shelves => {:libraries => {:id => libraries}}, :manifestations => {:carrier_type_id => carrier_types}, :items => {:circulation_statuses => {:name => "Removed"}}})
          when 4
            checkouts = Checkout.select(:item_id).map(&:item_id).uniq!
            items = Item.find(:all, 
              :joins => [:manifestation, :shelf => :library], 
              :conditions => {:shelves => {:libraries => {:id => libraries}}, :manifestations => {:carrier_type_id => carrier_types}})
            items.delete_if{|item|checkouts.include?(item.id)}
            list_size = items.size
          when 5
            query = get_query(ndcs, libraries, carrier_types)
            list_size = Item.recent.count(:all, 
              :joins => [:manifestation, :shelf => :library], 
              :conditions => query)
          when 6
            @items = []
            manifestations = SeriesStatement.latest_issues
            manifestations.each do |manifestation|
              manifestation.items.each do |item|
                @items << item if libraries.include?(item.shelf.library.id.to_s) rescue next
              end
            end
            list_size = @items.size
          end
        rescue
          list_size = 0
        end
      end

      #page
      page = (list_size / 36).to_f.ceil
      page = 1 if page == 0 and !error

      render :json => {:success => 1, :list_size => list_size, :page => page}
    end
  end 

  private
  def get_query(ndcs, libraries, carrier_types)
    query = ""
    ndcs.each {|ndc| query += "manifestations.ndc LIKE '#{ndc}%' OR "} if !ndcs.blank? and ndcs.length != 0
    query.gsub!(/OR\s$/, "AND ")
    query += "libraries.id IN (#{libraries.join(',')}) AND manifestations.carrier_type_id IN (#{carrier_types.join(',')})"
    return query
  end
end
