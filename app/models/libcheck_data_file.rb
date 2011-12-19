class LibcheckDataFile < ActiveRecord::Base
      has_attached_file :data_upload, :path => ":rails_root/private:url"
      attr_accessor :data_upload_file_name
      before_validation { self.file_name = self.data_upload_file_name}
      belongs_to :library_check
      validates :file_name, :uniqueness => {:scope => :library_check_id}
      validates_attachment_presence :data_upload, :message => I18n.t('activerecord.errors.messages.not_selected')
end
