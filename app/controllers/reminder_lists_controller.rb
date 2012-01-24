class ReminderListsController < ApplicationController

  def index
    @reminder_lists = ReminderList.all 
    respond_to do |format|
      format.html # index.rhtml
    end
  end

  def new
    @reminder_list = ReminderList.new
  end

  def show
    @reminder_list = ReminderList.find(params[:id])
    logger.info "aaaaa"
    logger.info @reminder_list.checkout.due_date
  end
end
