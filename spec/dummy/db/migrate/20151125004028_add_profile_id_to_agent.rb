class AddProfileIdToAgent < ActiveRecord::Migration[5.2]
  def change
    add_reference :agents, :profile, foreign_key: true
  end
end
