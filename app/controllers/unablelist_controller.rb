class UnablelistController < ApplicationController
  before_filter :check_librarian
  helper_method :get_real_libraries

  def index
    sort = User.set_sort(params[:sort_by], params[:order])
    page = params[:page] || 1
    role = current_user.try(:role) || Role.default_role
    @search = User.search do
      with(:unable).equal_to true
      with(:library).equal_to params[:library] if params[:library]
      with(:role).equal_to params[:role] if params[:role]
      with(:patron_type).equal_to params[:patron_type] if params[:patron_type]
      with(:required_role_id).less_than role.id
      with(:user_status).equal_to params[:user_status] if params[:user_status]
      order_by sort[:sort_by], sort[:order]
      order_by 'user_number', 'asc' if sort[:order_by] != 'user_number'
      if params[:format] == 'html' or params[:format].nil?
        facet :library
        facet :role
        facet :patron_type
        facet :user_status
        paginate :page => page.to_i, :per_page => Unablelist.default_per_page if params[:format] == 'html' or params[:format].nil?
      end
    end
    @users = @search.results

    respond_to do |format|
      format.html # index.html.erb
      format.pdf { send_data Unablelist.get_unable_list_pdf(@users, sort[:sort_by]).generate, :filename => Setting.unable_list_print_pdf.filename }
      format.tsv { send_data Unablelist.get_unable_list_tsv(@users), :filename => Setting.unable_list_print_tsv.filename }
    end
  end
end
