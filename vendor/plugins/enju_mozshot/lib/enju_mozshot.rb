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
        file.puts thumb
        file.close
        return file
      end
    end
  end
end
