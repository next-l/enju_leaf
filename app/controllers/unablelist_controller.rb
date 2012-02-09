class UnablelistController < ApplicationController
  before_filter :check_librarian

  def index
    @libraries = Library.find(:all).collect{|i| [ i.display_name, i.id ] }
    @selected_library = selected_library = params[:library][:id] if params[:library] and params[:library][:id]
    selected_library = @libraries.collect{|library| library[1]} if selected_library.blank?

    # set sort
    sort = 'user_number asc'
    case params[:sort_by]
    when 'library'
      sort = 'library_id asc, user_number asc'
    end

    # get data
    @page = params[:page] || 1
    if params[:output_pdf] or params[:output_tsv]
      @users = User.where(:unable => true, :library_id => selected_library).order(sort)
    else
      @users = User.where(:unable => true, :library_id => selected_library).order(sort).page(@page)
    end

    # output
    if params[:output_pdf]
      data = Unablelist.get_unable_list_pdf(@users, params[:sort_by])
      send_data data.generate, :filename => configatron.unable_list_print_pdf.filename; return
    end
    if params[:output_tsv]
      data = Unablelist.get_unable_list_tsv(@users)
      send_data data, :filename => configatron.unable_list_print_tsv.filename; return
    end
  end
end
