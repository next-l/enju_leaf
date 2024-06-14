class OaiController < ActionController::API
  def index
    provider = OaiProvider.new

    # ruby-oaiではフォーマット名を含んだメソッド(e.g. to_jpcoar)が呼ばれるが、
    # メソッド名にはドットを含められないため、リクエストを受け取ったときに変換
    # している
    case params['metadataPrefix']
    when 'jpcoar_2.0'
      request_hash = oai_params.to_h.merge({'metadataPrefix': 'jpcoar_20'})
    else
      request_hash = oai_params.to_h
    end

    response = provider.process_request(request_hash)
    render body: response, content_type: 'text/xml'
  end

  private

  def oai_params
    params.permit(:verb, :identifier, :metadataPrefix, :set, :from, :until, :resumptionToken)
  end
end
