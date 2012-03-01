class ExportItemRegistersController < ApplicationController
  before_filter :check_librarian

  def initialize
    @list_types = [[t('item_register.item_register'), 1],
                   [t('item_register.removing_list'), 2],
                   [t('item_register.audio_list'), 3]
                  ]
    super
  end

  def index
    @selected_list_type = 1
    @items_size = Item.count(:all, :joins => [:manifestation, :shelf => :library])
    @page = (@items_size / 36).to_f.ceil
    @page = 1 if @page == 0
  end

  def create
    flash[:message] = ""

    unless flash[:message].blank?
      @selected_list_type = params[:export_item_register][:list_type].to_i || 1 rescue nil
      @items_size = 0
      @page = 1
      render :index; return false
    else
      list_type = params[:export_item_register][:list_type]
      file_type = params[:export_item_register][:file_type]
      out_dir = "#{Rails.root}/private/system/item_registers/"
      # clear the out_dir
      Dir.foreach(out_dir){|file| File.delete(out_dir + file) rescue nil} rescue nil
  
      logger.error "SQL start at #{Time.now}"
      case list_type.to_i
      when 1 # item register
        file_name = "item_register"
        Item.export_item_register(out_dir, file_type)
      when 2 # removing list
        file_name = "removing_list"
        Item.export_removing_list(out_dir, file_type)
      when 3 # audio list
        file_name = "audio_list"
        Item.export_audio_list(out_dir, file_type)
      end
      send_file "#{out_dir}#{file_name}.#{file_type}"
      logger.error "created report: #{Time.now}"
      return true
    end
  end

  def get_list_size
    return nil unless request.xhr?
    unless params[:list_type].blank?
      list_type = params[:list_type]
      list_size = 0

      begin
        case list_type.to_i
        when 1 # item register
          list_size = Item.count(:all)
        when 2 # removing list
          list_size = Item.count(:all, :conditions => 'removed_at IS NOT NULL')
        when 3 # audio list
          carrier_type_ids = CarrierType.audio.inject([]){|ids, c| ids << c.id}
          list_size = Item.count(:all, :joins => :manifestation, :conditions => ["manifestations.carrier_type_id IN (?)", carrier_type_ids]) 
        when 4
          checkouts = Checkout.select(:item_id).map(&:item_id).uniq!
          items = Item.find(:all, :joins => [:manifestation, :shelf => :library], :conditions => {:shelves => {:libraries => {:id => libraries}}, :manifestations => {:carrier_type_id => carrier_types}})
          items.delete_if{|item|checkouts.include?(item.id)}
          list_size = items.size
        when 5
          query = get_query(ndcs, libraries, carrier_types)
          list_size = Item.recent.count(:all, :joins => [:manifestation, :shelf => :library], :conditions => query)
        end
      rescue
        list_size = 0
      end

      #page
      page = (list_size / 36).to_f.ceil
      page = 1 if page == 0 #and !error

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
