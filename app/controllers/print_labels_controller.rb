class PrintLabelsController < ApplicationController
  before_filter :check_client_ip_address
  before_filter :check_librarian

  def index
    user_list(params)

    @printed_types = %w(printed_type_full_name printed_type_address printed_type_postal_barcode)
    @selected_type = []
    flash[:error] = []
  end

  def get_user_label
    @printed_types = %w(printed_type_full_name printed_type_address printed_type_postal_barcode)
    @selected_type = params[:type]

    if params[:users] and @selected_type
      report = UserLabel.output_user_label_pdf(params[:users], @selected_type)
      send_data report.generate, :filename => "users.pdf", :type => 'application/pdf', :disposition => 'attachment'
      return
    end

    user_list(params)
    flash[:error] = []
    unless params[:users]
      flash[:error] << t('print_label.nousers')
    end
    unless @selected_type
      flash[:error] << t('print_label.notypes') 
    end

    @selected_type = @selected_type || []
    render :action => "index"
  end

  def search_user
    user_list(params)
  end

private
  def check_librarian
    if user_signed_in?
      unless current_user.has_role?('Librarian')
        access_denied; return
      end
    end
  end

  def user_list(params)
    query = params[:query].to_s
    @query = query.dup
    @count = {}

    query = params[:query].gsub("-", "") if params[:query]
    if query.size == 1
      query = "#{query}*"
    end

    sort = {:sort_by => 'created_at', :order => 'desc'}
    case params[:sort_by]
    when 'username'
      sort[:sort_by] = 'username'
    when 'telephone_number_1'
      sort[:sort_by] = 'telephone_number'
    when 'full_name'
      sort[:sort_by] = 'full_name'
    end
    case params[:order]
    when 'asc'
      sort[:order] = 'asc'
    when 'desc'
      sort[:order] = 'desc'
    end

    page = params[:page] || 1
    role = current_user.try(:role) || Role.default_role
    @date_of_birth = params[:birth_date].to_s.dup
    birth_date = params[:birth_date].to_s.gsub(/\D/, '') if params[:birth_date]
    flash[:message] = nil
    unless params[:birth_date].blank?
      begin
        date_of_birth = Time.zone.parse(birth_date).beginning_of_day.utc.iso8601
      rescue
        flash[:message] = t('user.birth_date_invalid')
      end
    end
    date_of_birth_end = Time.zone.parse(birth_date).end_of_day.utc.iso8601 rescue nil
    address = params[:address]
    @address = address

    query = "#{query} date_of_birth_d:[#{date_of_birth} TO #{date_of_birth_end}]" unless date_of_birth.blank?
    query = "#{query} address_text:#{address}" unless address.blank?

    @users = User.search do
      fulltext query
      order_by sort[:sort_by], sort[:order]
      with(:required_role_id).less_than role.id
    end.results

    @count[:query_result] = @users.total_entries
  end

end
