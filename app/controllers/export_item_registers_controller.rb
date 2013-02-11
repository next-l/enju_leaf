class ExportItemRegistersController < ApplicationController
  before_filter :check_librarian

  def initialize
    @list_types = [[t('item_register.item_register_all'), 1],
                   [t('item_register.removing_list'), 2],
                   [t('item_register.audio_list'), 3],
                   [t('item_register.item_register_book'),4],
                   [t('item_register.item_register_series'),5],
                   [t('item_register.item_register_article'),6],
                   [t('item_register.item_register_other'),7],
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
    list_type = params[:export_item_register][:list_type]
    file_type = params[:export_item_register][:file_type]
    unless %w(pdf tsv).include?(file_type)
      flash[:message] = t('item_register.invalid_file_type')
      render :index
      return false
    end

    method = 'export_item_register'
    args = []

    case list_type.to_i
    when 1 # all item register
      file_name = 'item_register_all'
      args << 'all'
    when 2 # removing list
      file_name = 'removing_list'
      method = 'export_removing_list'
    when 3 # audio list
      file_name = 'audio_list'
      method = 'export_audio_list'
    when 4 # book register
      file_name = 'item_register_book'
      args << 'book'
    when 5 # series register
      file_name = 'item_register_series'
      args << 'series'
    when 6 # article register
      file_name = 'item_register_article'
      args << 'article'
    when 7 # other register
      file_name = 'item_register_exinfo'
      args << 'exinfo'
    end

    job_name = Item.make_export_register_job(file_name, file_type, method, args, current_user)
    flash[:message] = t('item_register.export_job_queued', :job_name => job_name)
    redirect_to export_item_registers_path
    return true
  end

  def get_list_size
    if !request.xhr? || params[:list_type].blank?
      render :nothing => true, :status => :not_found
      return

    else
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
        when 4 # item register book
          list_size = Item.count(:all, :joins => :manifestation, :conditions => ["manifestations.manifestation_type_id in (?)", ManifestationType.type_ids('book')])
        when 5 # item register series
          list_size = Item.count(:all, :joins => :manifestation, :conditions => ["manifestations.manifestation_type_id in (?)", ManifestationType.type_ids('series')])
        when 6 # item register article
          list_size = Item.count(:all, :joins => :manifestation, :conditions => ["manifestations.manifestation_type_id in (?)", ManifestationType.type_ids('article')])
        when 7 # item register other
          list_size = Item.count(:all, :joins => :manifestation, :conditions => ["manifestations.manifestation_type_id in (?)", ManifestationType.type_ids('exinfo')])
        end
      rescue Exception => e
        logger.error e
        list_size = 0
      end

      #page
      page = (list_size / 36).to_f.ceil
      page = 1 if page == 0 #and !error

      render :json => {:success => 1, :list_size => list_size, :page => page}
    end
  end 
end
