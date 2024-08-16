module Paperclip
  class MediaTypeSpoofDetector
    private
    def type_from_file_command
      begin
        Paperclip.run("LANG=C file", "-b --mime-type :file", :file => @file.path)
      rescue Terrapin::CommandLineError
        ""
      end
    end
  end
end
