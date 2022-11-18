class ActiveStorage::Blobs::RedirectController < ActiveStorage::BaseController
  include ActiveStorage::SetBlob
  include Pundit::Authorization

  def show
    @blob.attachments.each do |attachment|
      authorize attachment.record
    end

    expires_in ActiveStorage.service_urls_expire_in
    redirect_to @blob.url(disposition: params[:disposition]), allow_other_host: true
  end
end
