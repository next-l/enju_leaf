class LibcheckShelf < ActiveRecord::Base
  has_many :libcheck_tmp_items
  attr_accessible :shelf_name, :stack_id, :shelf_grp_id
end
