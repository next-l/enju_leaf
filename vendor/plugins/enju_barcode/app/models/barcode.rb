class Barcode < ActiveRecord::Base
  belongs_to :barcodable, :polymorphic => true

  validates_presence_of :code_word
  validates_uniqueness_of :barcodable_id, :scope => :barcodable_type
  validates_uniqueness_of :code_word, :scope => :barcode_type
  before_create :generate_barcode

  def self.per_page
    10
  end

  def generate_barcode
    self.data = Barby::Code128B.new(self.code_word).to_png(:width => 150, :height => 70)
  end

  def is_readable_by(user, parent = nil)
    true
  end
end
