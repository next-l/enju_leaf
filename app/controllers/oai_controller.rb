class OaiController < ApplicationController
  before_action :check_policy, only: :provider

  def provider
    @oai = check_oai_params(params)
    if params[:verb] == 'GetRecord'
      get_record; return
    else
      from_and_until_times = set_from_and_until(Manifestation, params[:from], params[:until])
      from_time = @from_time = from_and_until_times[:from]
      until_time = @until_time = from_and_until_times[:until]

      if params[:resumptionToken]
        token = params[:resumptionToken]
      else
        token = '*'
      end

      # OAI-PMHのデフォルトの件数
      oai_per_page = 500
      search = Manifestation.search do
        order_by :updated_at, :desc
        paginate cursor: token, per_page: oai_per_page
        with(:updated_at).between(from_time..until_time)
        with(:required_role_id).equal_to Role.default.id
      end
      @manifestations = search.execute!.results

      if params[:verb] == 'ListSets'
        @series_statements = SeriesStatement.search do
          order_by :updated_at, :desc
          paginate cursor: token, per_page: oai_per_page
          with(:updated_at).between(from_time..until_time)
        end
      end

      if @manifestations.empty?
        @oai[:errors] << 'noRecordsMatch'
      end
    end

    respond_to do |format|
      format.xml {
        if @oai[:errors].empty?
          case params[:verb]
          when 'Identify'
            render template: 'oai/identify', content_type: 'text/xml'
          when 'ListMetadataFormats'
            render template: 'oai/list_metadata_formats', content_type: 'text/xml'
          when 'ListSets'
            render template: 'oai/list_sets', content_type: 'text/xml'
          when 'ListIdentifiers'
            render template: 'oai/list_identifiers', content_type: 'text/xml'
          when 'ListRecords'
            render template: 'oai/list_records', content_type: 'text/xml'
          else
            render template: 'oai/provider', content_type: 'text/xml'
          end
        else
          render template: 'oai/provider', content_type: 'text/xml'
        end
      }
    end
  end

  private
  def check_policy
    authorize Oai
  end

  def get_record
    if params[:identifier]
      begin
        @manifestation = Manifestation.find_by_oai_identifier(params[:identifier])
      rescue ActiveRecord::RecordNotFound
        @oai[:errors] << "idDoesNotExist"
      end
    else
      @oai[:errors] << "idDoesNotExist"
    end

    if @oai[:errors].empty?
      render template: 'oai/get_record', content_type: 'text/xml'
    else
      render template: 'oai/provider', content_type: 'text/xml'
    end
  end
end
