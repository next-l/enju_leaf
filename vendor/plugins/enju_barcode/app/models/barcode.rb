class Barcode < ActiveRecord::Base
  belongs_to :barcodable, :polymorphic => true

  validates_presence_of :code_word
  before_save :generate_barcode

  attr_accessor :start_rows, :start_cols

  def self.per_page
    10
  end

  def generate_barcode
    self.data = Barby::Code128B.new(self.code_word).to_svg(:width => 150, :height => 70)
  end

  def is_readable_by(user, parent = nil)
    true
  end
end
