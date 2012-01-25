class ReminderListsController < ApplicationController
  before_filter :check_librarian

  def initialize
    @reminder_list_statuses = ReminderList.statuses
    @selected_state = @reminder_list_statuses.collect {|s| s[:id]}
    super
  end

  def index
    flash[:reserve_notice] = ""
    unless params[:do_search].blank?
      query = params[:query].to_s.strip
      @query = query.dup
      query = "#{query}*" if query.size == 1
 
      tmp_state_list = params[:state] || []
      @selected_state = tmp_state_list.collect {|s| s.to_i }
      logger.info @selected_state
      if @selected_state.blank?  
        flash[:reserve_notice] << t('item_list.no_list_condition') + '<br />'
      end
      states = nil
    end
    page = params[:page] || 1

    state_ids = @selected_state
    unless query.blank?
      @reminder_lists = ReminderList.search do
        fulltext query
        with(:status, state_ids) 
        order_by(:id, :asc)
        paginate :page => page.to_i, :per_page => ReminderList.per_page
      end.results
    else
      @reminder_lists =  ReminderList.where(:status => state_ids).order('id').page(page)
    end

    # output reminder_list (postal_card or letter)
    unless @selected_state.blank? 
      if params[:output_reminder_postal_card] || params[:output_reminder_letter]
        output_pdf(params, query)
        return
      end
    end
  end

  def new
    @reminder_list = ReminderList.new
  end

  def edit
    @reminder_list = ReminderList.find(params[:id])
  end

  def show
    @reminder_list = ReminderList.find(params[:id])
  end

  def create
    @reminder_list = ReminderList.new(params[:reminder_list])
    if @reminder_list.save
      flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.reminder_list'))
      redirect_to(@reminder_list) 
    else
      render :action => "new" 
    end
  end

  def update
    @reminder_list = ReminderList.find(params[:id])
    if @reminder_list.update_attributes(params[:reminder_list])
      flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.reminder_list'))
      redirect_to(@reminder_list) 
    else
      render :action => "edit" 
    end
  end

  def destroy
    @reminder_list = ReminderList.find(params[:id])
    @reminder_list.destroy
    redirect_to(reminder_lists_url)
  end

  def output_pdf(params, query)
    logger.info "output_pdf."
  end

  private  
  def check_librarian
    access_denied unless current_user && current_user.has_role?('Librarian')
  end
end  
