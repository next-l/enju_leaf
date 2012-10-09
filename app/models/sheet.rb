class Sheet < ActiveRecord::Base
  attr_accessible :cell_x, :cell_y, :cell_h, :cell_w, :height, :margin_h,
                  :margin_w, :name, :note, :space_h, :space_w, :width

  paginates_per 10

  validates_presence_of :name, :height, :width, :margin_h, :margin_w, :space_h, :space_w, :cell_h, :cell_w

  default_scope order(:id)
end
