class LibraryCheckShelvesController < ApplicationController
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
