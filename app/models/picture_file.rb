class PictureFile < ActiveRecord::Base
  scope :attached, :conditions => ['picture_attachable_id > 0']
  belongs_to :picture_attachable, :polymorphic => true, :validate => true

  if configatron.uploaded_file.storage == :s3
    has_attached_file :picture, :storage => :s3, :styles => { :medium => "600x600>", :thumb => "100x100>" },
      :s3_credentials => "#{Rails.root.to_s}/config/s3.yml", :path => "picture_files/:id/:filename"
  else
    has_attached_file :picture, :styles => { :medium => "600x600>", :thumb => "100x100>" }, :path => ":rails_root/private:url"
  end
  validates_attachment_presence :picture
  validates_attachment_content_type :picture, :content_type => ["image/jpeg", "image/pjpeg", "image/png", "image/gif", "image/svg+xml"], :on => :create

  validates :picture_attachable_type, :presence => true, :inclusion => {:in => ['Event', 'Manifestation', 'Patron', 'Shelf']}
  validates_associated :picture_attachable
  default_scope :order => 'position'
  # http://railsforum.com/viewtopic.php?id=11615
  acts_as_list :scope => 'picture_attachable_type=\'#{picture_attachable_type}\''
  before_create :set_digest, :set_dimensions
  normalize_attributes :picture_attachable_type

  def self.per_page
    10
  end

  def set_digest(options = {:type => 'sha1'})
    if File.exists?(picture.queued_for_write[:original])
      self.file_hash = Digest::SHA1.hexdigest(File.open(picture.queued_for_write[:original].path, 'rb').read)
    end
  end

  def set_dimensions
    file = picture.queued_for_write[:original]
    if File.exists?(file)
      dimensions = ::Paperclip::Geometry.from_file(file)
      self.width = dimensions.width
      self.height = dimensions.height
    end
  end

  def extname
    ext = picture.content_type.split('/')[1].gsub('+xml', '') if picture.content_type
    if ext == 'pjpeg'
      ext = 'jpeg'
    else
      ext
    end
  end

  def content_type
    FileWrapper.get_mime(picture.path) rescue nil
  end
end
