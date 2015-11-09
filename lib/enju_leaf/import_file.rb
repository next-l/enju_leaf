module ImportFile
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_import_file_model
      include InstanceMethods
    end

    # 失敗したインポート処理を一括削除します。
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

    # インポートするファイルの文字コードをUTF-8に変換します。
    # @param [String] line 変換する文字列
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

    # インポート完了時のメッセージを送信します。
    def send_message
      sender = User.find(1)
      message_template = MessageTemplate.localized_template('import_completed', user.profile.locale)
      request = MessageRequest.new
      request.assign_attributes({sender: sender, receiver: user, message_template: message_template})
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
      NKF.nkf("#{output_encoding} -Lu", line)
    end

    def create_import_temp_file(attachment)
      tempfile = Tempfile.new(self.class.name.underscore)
      if ENV['ENJU_STORAGE'] == 's3'
        uploaded_file_path = attachment.expiring_url(10)
      else
        uploaded_file_path = attachment.path
        open(uploaded_file_path){|f|
          f.each{|line|
            tempfile.puts(convert_encoding(line))
          }
        }
      end
      tempfile.close
      tempfile
    end
  end
end
