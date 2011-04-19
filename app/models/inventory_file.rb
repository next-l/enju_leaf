class InventoryFile < ActiveRecord::Base
  has_many :inventories, :dependent => :destroy
  has_many :items, :through => :inventories
  belongs_to :user
  #has_attachment :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values']
  #validates_as_attachment
  has_attached_file :inventory, :path => ":rails_root/private:url"
  validates_attachment_content_type :inventory, :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values']
  validates_attachment_presence :inventory
  validates_presence_of :user

  paginates_per 10

  def import
    self.reload
    file = File.open(self.inventory.path)
    reader = file.read
    reader.split.each do |row|
      begin
        item = Item.find_by_sql(['SELECT * FROM items WHERE item_identifier = ?', row.to_s.strip])
        self.items << item if item
      rescue
        nil
      end
    end
    file.close
  end

end
