module ImportFile
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_import_file_model
      include InstanceMethods
    end

    def expire
      self.stucked.find_each do |file|
        file.destroy
      end
    end
  end

  module InstanceMethods
    def import_start
      case edit_mode
      when 'create'
        import
      when 'update'
        modify
      when 'destroy'
        remove
      else
        import
      end
    end

    def convert_encoding(line)
      if defined?(CharlockHolmes::EncodingDetector)
        begin
          case user_encoding
          when 'auto_detect'
            encoding = CharlockHolmes::EncodingDetector.detect(line)[:encoding]
          when nil
            encoding = CharlockHolmes::EncodingDetector.detect(line)[:encoding]
          else
            encoding = user_encoding
          end
          string = line.encode('UTF-8', user_encoding, universal_newline: true)
        rescue StandardError
          string = nkf_encode(line)
        end
      else
        string = nkf_encode(line)
      end
    end

    def send_message
      sender = User.find(1)
      message_template = MessageTemplate.localized_template('import_completed', user.locale)
      request = MessageRequest.new
      request.assign_attributes({:sender => sender, :receiver => user, :message_template => message_template}, as: :admin)
      request.save_message_body
      request.transition_to!(:sent)
    end

    private
    def nkf_encode(line)
      case user_encoding
      when 'auto_detect'
        output_encoding = '-w'
      when 'UTF-8'
        output_encoding = ''
      when 'Shift_JIS'
        output_encoding = '-Sw'
      when 'EUC-JP'
        output_encoding = '-Ew'
      else
        output_encoding = '-w'
      end
      string = NKF.nkf("#{output_encoding} -Lu", line)
    end
  end
end
