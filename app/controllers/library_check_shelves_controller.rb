class LibraryCheckShelvesController < ApplicationController
  add_breadcrumb "I18n.t('page.configuration')", 'page_configuration_path'
  add_breadcrumb "I18n.t('activerecord.models.library_check')", 'library_check_path(params[:library_check_id])'
  add_breadcrumb "I18n.t('activerecord.models.library_check_shelf')", ''
  load_and_authorize_resource

  def index
    @library_check_shelf = LibraryCheckShelf.new
    @library_check = LibraryCheck.find(:first, :conditions => ["id = ?", params[:library_check_id]])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @library_check_shelf }
    end
  end

end
