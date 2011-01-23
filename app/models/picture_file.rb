class PictureFile < ActiveRecord::Base
  scope :attached, :conditions => ['picture_attachable_id > 0']
  belongs_to :picture_attachable, :polymorphic => true, :validate => true

  if configatron.uploaded_file.storage == :s3
    has_attached_file :picture, :storage => :s3, :styles => { :medium => "500x500>", :thumb => "100x100>" },
      :s3_credentials => "#{Rails.root.to_s}/config/s3.yml", :path => "picture_files/:id/:filename"
  else
    has_attached_file :picture, :styles => { :medium => "500x500>", :thumb => "100x100>" }, :path => ":rails_root/private:url"
  end
  validates_attachment_presence :picture
  validates_attachment_content_type :picture, :content_type => %r{image/.*}

  validates_associated :picture_attachable
  validates_presence_of :picture_attachable, :picture_attachable_type #, :unless => :parent_id, :on => :create
  default_scope :order => 'position'
  # http://railsforum.com/viewtopic.php?id=11615
  acts_as_list :scope => 'picture_attachable_id=#{picture_attachable_id} AND picture_attachable_type=\'#{picture_attachable_type}\''
  before_create :set_digest, :set_dimensions

  def self.per_page
    10
  end

  def set_digest(options = {:type => 'sha1'})
    if File.exists?(picture.queued_for_write[:original])
      self.file_hash = Digest::SHA1.hexdigest(File.open(picture.queued_for_write[:original], 'rb').read)
    end
  end

  def set_dimensions
    file = picture.queued_for_write[:original]
    if File.exists?(file)
      dimensions = Paperclip::Geometry.from_file(file)
      self.width = dimensions.width.to_i
      self.height = dimensions.height.to_i
    end
  end

  def extname
    picture.content_type.split('/')[1] if picture.content_type
  end

  def content_type
    FileWrapper.get_mime(picture.path) rescue nil
  end
end
