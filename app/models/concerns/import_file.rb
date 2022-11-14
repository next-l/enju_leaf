module ImportFile
  extend ActiveSupport::Concern

  # 失敗したインポート処理を一括削除します。
  def self.expire
    self.stucked.find_each do |file|
      file.destroy
    end
  end

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
        line.encode('UTF-8', encoding, universal_newline: true)
      rescue StandardError
        nkf_encode(line)
      end
    else
      nkf_encode(line)
    end
  end

  # インポート完了時のメッセージを送信します。
  def send_message(mailer)
    sender = User.find(1)
    message = Message.create!(
      recipient: user.username,
      sender: sender,
      body: mailer.body.raw_source,
      subject: mailer.subject
    )
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
    tempfile.write convert_encoding(attachment.download)
    tempfile.close
    tempfile
  end
end
