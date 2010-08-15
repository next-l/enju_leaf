module EnjuMozshot
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_mozshot
      include EnjuMozshot::InstanceMethods
    end
  end

  module InstanceMethods
    def screen_shot
      if access_address.present?
        url = "http://mozshot.nemui.org/shot?#{access_address}"
        thumb = Rails.cache.fetch("manifestation_mozshot_#{id}"){open(url).read}
        file = Tempfile.new('thumb')
        if RUBY_VERSION > '1.9'
          file.puts thumb.dup.force_encoding('UTF-8')
        else
          file.puts thumb
        end
        file.close
        return file
      end
    end
  end
end
