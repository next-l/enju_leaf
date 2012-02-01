class UnablelistController < ApplicationController
  before_filter :check_librarian

  def index
    @libraries = Library.find(:all).collect{|i| [ i.display_name, i.id ] }
    @selected_libtary = selected_library = nil
    @selected_library = selected_library =  params[:library][:id] if params[:library]

    selected_library = @libraries.collect{|library| library[1]} if selected_library.blank?
    sort = 'user_number asc'
    case params[:sort_by]
    when 'library'
      sort = 'library_id asc, user_number asc'
    end

    # output
    if params[:output]
      @users = User.where(:unable => true, :library_id => selected_library).order(sort)
      # make file
      data = Unablelist.output(@users, params[:sort_by])
      send_data data.generate, :filename => configatron.unablelist_print.filename
      return
    end

    @page = params[:page] || 1
    @users = User.where(:unable => true, :library_id => selected_library).order(sort).page(@page)
  end
end
