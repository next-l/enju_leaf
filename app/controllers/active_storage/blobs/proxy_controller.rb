class ActiveStorage::Blobs::ProxyController < ActiveStorage::BaseController
  include ActiveStorage::SetBlob
  include ActiveStorage::Streaming
  include Pundit::Authorization

  def show
    @blob.attachments.each do |attachment|
      authorize attachment.record
    end

    if request.headers["Range"].present?
      send_blob_byte_range_data @blob, request.headers["Range"]
    else
      http_cache_forever public: true do
        response.headers["Accept-Ranges"] = "bytes"
        response.headers["Content-Length"] = @blob.byte_size.to_s

        send_blob_stream @blob, disposition: params[:disposition]
      end
    end
  end
end
