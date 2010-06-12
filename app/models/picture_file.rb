class PictureFile < ActiveRecord::Base
  scope :attached, :conditions => ['picture_attachable_id > 0']
  belongs_to :picture_attachable, :polymorphic => true, :validate => true

  has_attached_file :picture, :styles => { :medium => "500x500>", :thumb => "100x100>" }, :path => ":rails_root/private:url"
  validates_attachment_presence :picture
  validates_attachment_content_type :picture, :content_type => %r{image/.*}

  validates_associated :picture_attachable
  validates_presence_of :picture_attachable, :picture_attachable_type #, :unless => :parent_id, :on => :create
  default_scope :order => 'position'
  # http://railsforum.com/viewtopic.php?id=11615
  acts_as_list :scope => 'picture_attachable_id=#{picture_attachable_id} AND picture_attachable_type=\'#{picture_attachable_type}\''
  after_create :set_digest

  def self.per_page
    10
  end

  def set_digest(options = {:type => 'sha1'})
    if File.exists?(picture.path)
      self.file_hash = Digest::SHA1.hexdigest(File.open(picture.path, 'rb').read)
      save(:validate => false)
    end
  end

  def extname
    content_type.split('/')[1] if content_type
  end

  def content_type
    FileWrapper.get_mime(picture.path) rescue nil
  end
end
