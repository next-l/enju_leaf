class UpdateAcquiredAtString < ActiveRecord::Migration
  def up
    Item.update_all("acquired_at_string = TO_CHAR(acquired_at, 'YYYY-MM-DD')", ['acquired_at IS NOT NULL AND acquired_at_string IS NULL'])
  end

  def down
    Item.update_all("acquired_at_string = null")
  end
end
