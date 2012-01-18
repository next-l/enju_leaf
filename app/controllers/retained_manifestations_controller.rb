class RetainedManifestationsController < ApplicationController
  include ReservesHelper
  before_filter :check_librarian

  def index
    page = params[:page] || 1
    @librarlies = Library.find(:all).collect{|i| [ i.display_name, i.id ] }
    @selected_library = params[:library][:id] unless params[:library].blank?
    @information_types = @selected_method = Reserve.information_types

    # first move
    if params[:do_search].blank?
      @retained_manifestations = Reserve.retained.order('user_id DESC, expired_at ASC').page(params[:page])
      return
    end

    # check conditions 
    flash[:notice] = ""
    flash[:notice] << t('item_list.no_list_condition') + '<br />'if params[:do_search] and params[:all_method].blank? and params[:method].blank?
    params[:method] ? @selected_method = params[:method].clone : @selected_method = []
    params[:method].concat(['3', '4', '5', '6', '7']) if !params[:method].blank? and params[:method].include?('2')

    # set query
    query = params[:query].to_s.strip
    @query = query.dup
    query = params[:query].gsub("-", "") if params[:query]
    query = "#{query}*" if query.size == 1
    @address = params[:address]
    @date_of_birth = params[:birth_date].to_s.dup
    birth_date = params[:birth_date].to_s.gsub(/\D/, '') if params[:birth_date]
    unless params[:birth_date].blank?
      begin
        date_of_birth = Time.zone.parse(birth_date).beginning_of_day.utc.iso8601
      rescue
        flash[:notice] << t('user.birth_date_invalid')
      end
    end
    date_of_birth_end = Time.zone.parse(birth_date).end_of_day.utc.iso8601 rescue nil 

    if query.blank? and @address.blank? and @date_of_birth.blank?
      if params[:library][:id].blank?
        @retained_manifestations = Reserve.where(:information_type_id => params[:method]).retained.order('user_id DESC, expired_at ASC').page(params[:page])
        @retained_manifestations_output = Reserve.where(:information_type_id => params[:method]).retained.order('user_id DESC, expired_at ASC') if params[:output]
      else
        @retained_manifestations = Reserve.where(:information_type_id => params[:method], :receipt_library_id => params[:library][:id]).retained.order('user_id DESC, expired_at ASC').page(params[:page])
        @retained_manifestations_output = Reserve.where(:information_type_id => params[:method], :receipt_library_id => params[:library][:id]).retained.order('user_id DESC, expired_at ASC') if params[:output]
      end
    else
      query = "#{query} date_of_birth_d: [#{date_of_birth} TO #{date_of_birth_end}]" unless date_of_birth.blank?
      query = "#{query} address_text: #{@address}" unless @address.blank?
      @retained_manifestations = Reserve.search do
        fulltext query
        with(:state).equal_to 'retained'
        with(:receipt_library_id).equal_to params[:library][:id] unless params[:library][:id].blank?
        with(:information_type_id, params[:method]) 
        order_by(:user_id, :desc)
        order_by(:expired_at, :asc)
        paginate :page => page.to_i, :per_page => Reserve.per_page
     end.results
     if params[:output]
       @retained_manifestations_output = Reserve.search do
          fulltext query
          with(:state).equal_to 'retained'
          with(:receipt_library_id).equal_to params[:library][:id] unless params[:library][:id].blank?
          with(:information_type_id, params[:method]) unless params[:method].blank? 
          order_by(:user_id, :desc)
          order_by(:expired_at, :asc)
       end.results
     end
    end
    # output
    output(@retained_manifestations_output) if params[:output]
  end

  def set_retained
    @reserve = Reserve.find(params[:reserve][:id])
    @reserve.retained = params[:reserve][:retained]
    @reserve.save!(:validate => false)
    respond_to do |format|
      format.html { redirect_to retained_manifestations_path }
      format.xml  { head :ok }
    end
  end

  private
  def output(retained_manifestations)
    #retained_manifestations = Reserve.retained.order('reserves.user_id, reserves.receipt_library_id, reserves.created_at DESC')

    require 'thinreports'
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'retained_manifestations.tlf')

    report.events.on :page_create do |e|
      e.page.item(:page).value(e.page.no)
    end
    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:total).value(e.report.page_count)
      end
    end

    report.start_new_page do |page|
      page.item(:date).value(Time.now)

      before_user = nil
      before_receipt_library = nil
      retained_manifestations.each do |r|
        page.list(:list).add_row do |row|
          if before_user == r.user_id 
            row.item(:line1).hide
            row.item(:user).hide
          end
          if before_receipt_library == r.receipt_library_id and before_user == r.user_id
            row.item(:line2).hide
            row.item(:receipt_library).hide
          end
          row.item(:receipt_library).value(Library.find(r.receipt_library_id).display_name)
          row.item(:title).value(r.manifestation.original_title)
          user = r.user.patron.full_name
          if SystemConfiguration.get("reserve_print.old") == true and  r.user.patron.date_of_birth
            age = (Time.now.strftime("%Y%m%d").to_f - r.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
            age = age.to_i
            user = user + '(' + age.to_s + t('activerecord.attributes.patron.old')  +')'
          end
          row.item(:user).value(user)
          information_method = i18n_information_type(r.information_type_id)
          information_method += ': ' + Reserve.get_information_method(r) if r.information_type_id != 0 and !Reserve.get_information_method(r).nil?
          row.item(:information_method).value(information_method)
        end
        before_user = r.user_id
        before_receipt_library = r.receipt_library_id
      end
    end
    send_data report.generate, :filename => configatron.configatron.retained_manifestations_print.filename, :type => 'application/pdf', :disposition => 'attachment'
  end
end
