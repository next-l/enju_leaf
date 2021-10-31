module EnjuManifestationViewer
  module EnjuManifestation
    extend ActiveSupport::Concern

    def youtube_id
      if access_address
        url = ::Addressable::URI.parse(access_address)
        if url.host =~ /youtube\.com$/ && (url.path == "/watch")
          return CGI.parse(url.query)["v"][0]
        end
      end
    end

    def nicovideo_id
      if access_address
        url = ::Addressable::URI.parse(access_address)
        if url.host =~ /nicovideo\.jp$/ && url.path =~ /^\/watch/
          return url.path.split("/")[2]
        end
      end
    end

    def flickr
      if access_address
        url = ::Addressable::URI.parse(access_address)
        paths = url.path.split('/')
        if url.host =~ /^www\.flickr\.com$/ && (paths[1] == 'photos') && paths[2]
          info = {}
          if paths[3] == "sets"
            info[:user] = paths[2]
            info[:set_id] = paths[4]
            return info
          end
        end
      end
    end
  end
end
