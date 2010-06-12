module EnjuManifestationViewer
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_manifestation_viewer
      include EnjuManifestationViewer::InstanceMethods
    end
  end

  module InstanceMethods

    def youtube_id
      if access_address
        url = URI.parse(access_address)
        if url.host =~ /youtube\.com$/ and url.path == "/watch"
          return CGI.parse(url.query)["v"][0]
        end
      end
    end

    def nicovideo_id
      if access_address
        url = URI.parse(access_address)
        if url.host =~ /nicovideo\.jp$/ and url.path =~ /^\/watch/
          return url.path.split("/")[2]
        end
      end
    end

    def flickr
      if access_address
        url = URI.parse(access_address)
        paths = url.path.split('/')
        if url.host =~ /^www\.flickr\.com$/ and paths[1] == 'photos' and paths[2]
          info = {}
          if paths[3] == "sets"
            info[:user] = paths[2]
            info[:set_id] = paths[4]
          end
        end
      end
    end

  end
end
