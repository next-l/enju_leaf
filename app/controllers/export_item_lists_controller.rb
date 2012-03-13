class ExportItemListsController < ApplicationController
  before_filter :check_librarian

  def initialize
    @list_types = [[t('item_list.shelf_list'),1],
                   [t('item_list.call_number_list'), 2],
                   [t('item_list.removed_list'), 3],
                   [t('item_list.unused_list'), 4],
                   [t('item_list.series_statements_list'), 8],
                   [t('item_list.new_item_list'), 5],
                   [t('item_list.latest_list'), 6],
                   [t('item_list.new_book_list'), 7]
                 ]
    @libraries = Library.all
    @carrier_types = CarrierType.all
    @bookstores = Bookstore.all
    @selected_list_type = 1
    @selected_library, @selected_carrier_type, @selected_bookstore = [], [], []
    super
  end

  def index
    @selected_library = @libraries.inject([]){ |library_ids, library| library_ids << library.id.to_i }
    @selected_carrier_type = @carrier_types.inject([]){ |carrier_type_ids, carrier_type| carrier_type_ids << carrier_type.id.to_i }
    @selected_bookstore = @bookstores.inject([]){ |bookstore_ids, bookstore| bookstore_ids << bookstore.id.to_i }
    @items_size = Item.count(:all, :joins => [:manifestation, :shelf => :library])
    @page = (@items_size / 36).to_f.ceil
  end

  def create
    flash[:message] = ""

    # check checked
    @selected_list_type = params[:export_item_list][:list_type]
    @selected_library = params[:library].inject([]){ |library_ids, library_id| library_ids << library_id.to_i } if params[:library]
    @selected_carrier_type = params[:carrier_type].inject([]){ |carrier_type_ids, carrier_type_id| carrier_type_ids << carrier_type_id.to_i } if params[:carrier_type]
    @selected_bookstore = params[:bookstore].inject([]){ |bookstore_ids, bookstore_id| bookstore_ids << bookstore_id.to_i } if params[:bookstore]
    all_bookstore = params[:all_bookstore]
    flash[:message] << t('item_list.no_list_condition') + '<br />' if @selected_library.blank? || @selected_carrier_type.blank? || @selected_bookstore.blank?

    # check ndc
    @ndc = params[:ndc]
    unless @ndc.blank? 
      ndcs = @ndc.gsub(' ', '').split(",") 
      ndcs.each do |ndc|
        unless ndc =~ /^\d{3}$/
          logger.error ndc
          flash[:message] << t('item_list.invalid_ndc') + '<br />'
          break
        end
      end
    end

    # check acquired_at
    @acquired_at = params[:acquired_at].to_s.dup
    acquired_at = params[:acquired_at].to_s.gsub(/\D/, '') if params[:acquired_at]
    unless params[:acquired_at].blank?
      begin
        acquired_at = Time.zone.parse(acquired_at).beginning_of_day.utc.iso8601
      rescue
        flash[:message] << t('item_list.acquired_at_invalid')
      end
    end

    unless flash[:message].blank?
      @items_size = 0
      @page = 0
      render :index; return false
    else
      list_type = params[:export_item_list][:list_type]
      file_type = params[:export_item_list][:file_type]

      # get data
      logger.info "SQL start at #{Time.now}"
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
        checkouts = Checkout.select(:item_id).map(&:item_id).uniq
        @items = Item.find(:all, 
          :joins => [:manifestation, :shelf => :library], 
          :conditions => {:shelves => {:libraries => {:id => @selected_library}}, 
          :manifestations => {:carrier_type_id => @selected_carrier_type}}, 
          :order => 'libraries.id, manifestations.carrier_type_id, items.shelf_id, items.item_identifier')
        @items.delete_if{|item|checkouts.include?(item.id)} if checkouts
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
            if @selected_library.include?(item.shelf.library.id)
              if all_bookstore == "true"
                @items << item 
              else
                @items << item if @selected_bookstore.include?(item.bookstore_id)
              end
            end
          end
        end
        sort_series_statements
        filename = t('item_list.latest_list')
      when 7
        query = get_query(ndcs, @selected_library, @selected_carrier_type)
        day_ago = Time.zone.now - SystemConfiguration.get("new_book_term").day
        day_ago = "'" + (day_ago.beginning_of_day.utc.iso8601).to_s + "'"
        query += " AND manifestations.date_of_publication >= #{day_ago}"
        @items = Item.find(:all, 
          :joins => [:manifestation, :shelf => :library], 
          :conditions => query ,
          :order => 'libraries.id, manifestations.carrier_type_id, items.shelf_id, items.item_identifier, manifestations.original_title')
        filename = t('item_list.new_book_list')
      when 8
        @items = get_series_statements_item(@selected_library, all_bookstore, @selected_bookstore, acquired_at)
        sort_series_statements
        filename = t('item_list.series_statements_list')
      end
      logger.info "SQL end at #{Time.now}\nfound #{@items.length rescue 0} records"
      logger.info "list_type=#{list_type.to_i} file_type=#{file_type}"

      # make file
      begin
        if file_type == 'pdf'
          case list_type.to_i
          when 3
            data = Item.make_export_removed_list_pdf(@items)
          when 5
            data = Item.make_export_new_item_list_pdf(@items)
          when 6
            data = Item.make_export_series_statements_latest_list_pdf(@items)
          when 7
            data = Item.make_export_new_book_list_pdf(@items)
          when 8
            data = Item.make_export_series_statements_list_pdf(@items, acquired_at)
          else
            data = Item.make_export_item_list_pdf(@items, filename)
          end
          unless data
            flash[:message] = t('item_list.no_record')
            @items_size = 0
            @page = 0
            render :index
            return false
          end
          send_data data.generate, :filename => "#{filename}.pdf"
        elsif file_type == 'tsv'
          case list_type.to_i
          when 3
            data = Item.make_export_removed_list_tsv(@items)
          when 5
            data = Item.make_export_new_item_list_tsv(@items)
          when 6
            data = Item.make_export_series_statements_latest_list_tsv(@items)
          when 7
            data = Item.make_export_new_book_list_tsv(@items)
          when 8
            data = Item.make_export_series_statements_list_tsv(@items, acquired_at)
          else
            data = Item.make_export_item_list_tsv(@items)
          end
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
      all_bookstore = params[:all_bookstore]
      bookstores = params[:bookstores]
      all_bookstores = params[:all_bookstore]
      acquired_at = params[:acquired_at]
      libraries = libraries.map{|library|library.to_i} if libraries
      carrier_types = carrier_types.map{|carrier_type|carrier_type.to_i} if carrier_types
      bookstores = bookstores.map{|bookstore|bookstore.to_i} if bookstores

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

      # check acquired_at
      unless acquired_at.blank?
        acquired_at = params[:acquired_at].to_s.dup
        acquired_at = params[:acquired_at].to_s.gsub(/\D/, '') if params[:acquired_at]
        begin
          acquired_at = Time.zone.parse(acquired_at).beginning_of_day.utc.iso8601
        rescue
          error = true
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
            checkouts = Checkout.select(:item_id).map(&:item_id).uniq
            items = Item.find(:all, 
              :joins => [:manifestation, :shelf => :library], 
              :conditions => {:shelves => {:libraries => {:id => libraries}}, :manifestations => {:carrier_type_id => carrier_types}})
            items.delete_if{|item|checkouts.include?(item.id)} if checkouts
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
                if libraries.include?(item.shelf.library.id)
                  if all_bookstore == "true"
                    @items << item
                  else
                    @items << item if bookstores.include?(item.bookstore_id)
                  end
                end
              end
            end
            list_size = @items.size
          when 7
            query = get_query(ndcs, libraries, carrier_types)
            day_ago = Time.zone.now - SystemConfiguration.get("new_book_term").day
            day_ago = "'" + (day_ago.beginning_of_day.utc.iso8601).to_s + "'"
            query += " AND manifestations.date_of_publication >= #{day_ago}"
            list_size = Item.count(:all, 
              :joins => [:manifestation, :shelf => :library], 
              :conditions => query ,
              :order => 'libraries.id, manifestations.carrier_type_id, items.shelf_id, items.item_identifier, manifestations.original_title')
          when 8
            @items = get_series_statements_item(libraries, all_bookstore, bookstores, acquired_at)
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

  def get_series_statements_item(libraries, all_bookstore, bookstores, acquired_at)
    @items = []
    series_statements = SeriesStatement.all
    series_statements.each do |series_statement|
      series_statement.manifestations.each do |manifestation|
        manifestation.items.each do |item|
          if libraries.include?(item.shelf.library.id)
            if all_bookstore == "true"
              unless acquired_at.blank?
                @items << item if item.acquired_at >= acquired_at
              else
                @items << item
              end
            else
              if bookstores.include?(item.bookstore_id)
                unless acquired_at.blank?
                  @items << item if item.acquired_at >= acquired_at
                else
                  @items << item
                end
              end
            end
          end
        end
      end
    end
    return @items
  end

  def sort_series_statements
    @items = @items.sort{|a, b|
      if a.shelf.library.id.to_i != b.shelf.library.id.to_i 
        a.shelf.library.id.to_i <=> b.shelf.library.id.to_i
      elsif a.acquired_at.to_i != b.acquired_at.to_i
        a.acquired_at.to_i <=> b.acquired_at.to_i
      elsif a.bookstore_id.to_i != b.bookstore_id.to_i 
        a.bookstore_id.to_i <=> b.bookstore_id.to_i
      elsif a.item_identifier.to_s != b.item_identifier.to_s
        a.item_identifier.to_s <=> b.item_identifier.to_s
      else
        a.id <=> b.id
      end
    }
  end
end
