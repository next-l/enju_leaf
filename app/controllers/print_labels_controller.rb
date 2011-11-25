class PrintLabelsController < ApplicationController
  before_filter :check_client_ip_address
#  load_and_authorize_resource

  def index
    if user_signed_in?
      unless current_user.has_role?('Librarian')
        access_denied; return
      end
    end
    user_list(params)
  end

  def get_user_label
    user_ids = params[:users]
    report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/print_labels/patron_label"
    user_ids.each do |user_id|
      user = User.find(user_id)
      report.start_new_page
      report.page.item(:full_name).value(user.patron.full_name) if user && user.patron
    end
    send_data report.generate, :filename => "users.pdf", :type => 'application/pdf', :disposition => 'attachment'
  end

  def search_user
    user_list(params)
  end

private
  def user_list(params)
    query = params[:query].to_s
    @query = query.dup
    @count = {}

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

    query = params[:query].gsub("-", "") if params[:query]
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

    query = "#{query} date_of_birth_d: [#{date_of_birth} TO #{date_of_birth_end}]" unless date_of_birth.blank?
    query = "#{query} address_text: #{address}" unless address.blank?

    @users = User.search do
      fulltext query
      order_by sort[:sort_by], sort[:order]
      with(:required_role_id).less_than role.id
    end.results

    @count[:query_result] = @users.total_entries
  end

end
