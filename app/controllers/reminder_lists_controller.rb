class ReminderListsController < ApplicationController
  before_filter :check_librarian

  def initialize
    @reminder_list_statuses = ReminderList.statuses
    super
  end

  def index
    query = params[:query].to_s.strip
    @query = query.dup
    query = "#{query}*" if query.size == 1
    page = params[:page] || 1

    unless query.blank?
      @reminder_lists = ReminderList.search do
        fulltext query
        paginate :page => page.to_i, :per_page => ReminderList.per_page
      end.results
    else
      @reminder_lists =  ReminderList.page(page)
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

  private  
  def check_librarian
    access_denied unless current_user && current_user.has_role?('Librarian')
  end
end  
