# encoding: utf-8

class NacsisUserRequestsController < InheritedResources::Base
  include FormInputUtils

  before_filter :authenticate_user!
  before_filter :load_records, :only => [:index]
  before_filter :build_new_record, :only => [:new, :create]
  load_and_authorize_resource :only => [:show, :edit, :update, :destroy]

  class Error < RuntimeError; end
  class InvalidPrametresError < Error; end
  class RecordNotFoundError < Error; end

  rescue_from InvalidPrametresError, RecordNotFoundError do |ex|
    render :nothing => true, :status => :forbidden
  end

  class NacsisUserRequestSearch
    include FormInputUtils
    SORTABLE_FIELDS = {
      'subject_heading' => true,
      'request_type' => true,
      'created_at' => true,
      'user_number' => true,
      'state' => true,
    }

    def initialize(options = {})
      model_class = NacsisUserRequest
      @search = Sunspot.new_search(model_class)

      per_page = normalize_integer(options[:per_page]) || model_class.default_per_page
      page = normalize_integer(options[:page]) || 1
      sort_by = options[:sort_by].try(:to_s)
      sort_by = nil unless SORTABLE_FIELDS.include?(sort_by)
      sort = options[:sort].try(:to_s)
      sort = nil if sort_by.blank?
      sort = 'asc' if sort && /\A(?:asc|desc)\z/ !~ sort
      facet_fields = [options[:facet]].flatten.compact

      @search.build do
        paginate :per_page => per_page, :page => page
        if fields = SORTABLE_FIELDS[sort_by]
          fields = [sort_by] if fields == true
          fields.each {|field| order_by field, sort }
        end
        facet_fields.each {|field| facet field }
      end
    end

    # 検索を実行する
    # 検索条件に問題があった場合にはnilを返す
    def execute
      if valid?
        @search.execute
      else
        nil
      end
    end

    def filter_by_user_id!(form_input)
      filter_by_integer_field!(:user_id, form_input)
    end

    def filter_by_state!(form_input)
      filter_by_selection_field!(:state, form_input) {|x| /\A\d+\z/ =~ x }
    end

    def filter_by_request_type!(form_input)
      filter_by_selection_field!(:request_type, form_input) {|x| /\A\d+\z/ =~ x }
    end

    def filter_by_ncid!(form_input)
      filter_by_string_field!(:ncid, form_input)
    end

    def filter_by_created_at!(form_input)
      filter_by_time_field!(:created_at, form_input)
    end

    def filter_by_query!(form_input)
      filter_by_fulltext!(form_input)
    end

    def valid?
      @search.present?
    end

    private

      def filter_by_selection_field!(field, form_input, &block)
        return if @search.blank?
        return if form_input.blank?

        valid, invalid = normalize_multi_choice(form_input, &block)
        if valid.blank? && invalid.blank? # form_input is blank
          return # noop
        end

        if valid.present?
          @search.build { with(field, valid) }
        else
          @search = nil
        end
      end

      def filter_by_integer_field!(field, form_input)
        return if @search.blank?
        return if form_input.blank?

        query = normalize_integer(form_input)
        return if query.blank?

        @search.build { with(field, query) }
      end

      def filter_by_string_field!(field, form_input)
        return if @search.blank?
        return if form_input.blank?

        query = normalize_query_string(form_input)
        return if query.blank?

        @search.build { with(field, query) }
      end

      def filter_by_time_field!(field, form_input)
        return if @search.blank?
        return if form_input.blank?

        date_from, date_to = form_input
        return if date_from.blank? && date_to.blank?

        r_begin, r_end = construct_time_range(date_from, date_to)
        if r_begin.blank? && date_from.present? ||
            r_end.blank? && date_to.present?
          @search = nil
          return
        end

        if r_begin && r_end
          @search.build { with(:created_at, r_begin..r_end) }
        elsif r_begin
          @search.build { with(:created_at).greater_than_or_equal_to(r_begin) }
        else
          @search.build { with(:created_at).less_than_or_equal_to(r_end) }
        end
      end

      def filter_by_fulltext!(form_input)
        return if @search.blank?
        return if form_input.blank?

        query = each_query_word(form_input)
        return if query.blank?

        if query.size == 1 && query.first.size == 1
          query = ["*#{query.first}*"]
        end
        @search.build { fulltext(query.join(' ')) }
      end

      def normalize_multi_choice(form_input, &block)
        [form_input].flatten.map(&:to_s).partition(&block)
      end
  end

  def create
    set_librarian_note
    set_user_note
    super
  end

  def update
    set_librarian_note
    set_user_note
    super
  end

  private

    def load_records
      search = NacsisUserRequestSearch.new(
        :per_page => params[:per_page], :page => params[:page],
        :sort_by => params[:sort_by], :sort => params[:sort],
        :facet => [:request_type, :state])

      unless current_user.has_role?('Librarian')
        search.filter_by_user_id!(current_user.id)
      end

      search.filter_by_state!(params[:state])
      search.filter_by_request_type!(params[:request_type])
      search.filter_by_ncid!(params[:ncid])
      search.filter_by_created_at!([params[:created_from], params[:created_to]])
      search.filter_by_query!(params[:query])

      @nacsis_user_request_search = search.execute
      @nacsis_user_requests = @nacsis_user_request_search.try(:results) || []
    end

    def build_new_record
      if action_name == 'new'
        form_input = params
      else
        form_input = params[:nacsis_user_request]
      end

      ncid = form_input[:ncid].to_s
      manifestation_type = normalize_query_string(form_input[:manifestation_type])
      request_type = normalize_integer(form_input[:request_type])
      if ncid.blank? || manifestation_type.blank? || request_type.blank?
        logger.debug 'required ncid param is not given' if ncid.blank?
        logger.debug 'required manifestation_type param is not given' if manifestation_type.blank?
        logger.debug 'required request_type param is not given' if request_type.blank?
        raise InvalidPrametresError, 'required params are missing'
      end

      @manifestation_type = manifestation_type

      @nacsis_user_request = NacsisUserRequest.new
      @nacsis_user_request.ncid = ncid
      @nacsis_user_request.request_type = request_type
      @nacsis_user_request.user = current_user
      if !@nacsis_user_request.valid? &&
          (@nacsis_user_request.errors[:request_type] ||
            @nacsis_user_request.errors[:user] ||
            @nacsis_user_request.errors[:user_id])
        msg = @nacsis_user_request.errors.full_messages.join
        logger.debug "invalid nacsis_user_request: #{msg}"
        raise InvalidPrametresError, msg
      end

      begin
        db = @manifestation_type.to_sym
        retval = NacsisCat.search(:id => form_input[:ncid], :dbs => [db])
        cat = retval[db].first
      rescue ArgumentError => ex
        logger.debug "NACSIS-CAT search failed: #{ex.message} (#{ex.class})"
        raise InvalidPrametresError, ex.message
      end

      if cat.blank?
        logger.debug "no such record: ID=#{form_input[:ncid]}"
        raise RecordNotFoundError
      end
      cat.request_summary.each_pair do |name, value|
        @nacsis_user_request[name] = value
      end
    end

    def set_user_note
      return unless params[:nacsis_user_request].is_a?(Hash)
      return unless params[:nacsis_user_request][:user_note]

      user_note = params[:nacsis_user_request].delete(:user_note)
      @nacsis_user_request.user_note = user_note
    end

    def set_librarian_note
      return unless params[:nacsis_user_request].is_a?(Hash)
      return unless params[:nacsis_user_request][:librarian_note]

      librarian_note = params[:nacsis_user_request].delete(:librarian_note)
      if current_user.has_role?('Librarian')
        @nacsis_user_request.librarian_note = librarian_note
      end
    end
end
