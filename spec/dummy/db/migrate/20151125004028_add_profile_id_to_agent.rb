class AddProfileIdToAgent < ActiveRecord::Migration[5.2]
  def change
    add_reference :agents, :profile, foreign_key: true, type: :uuid
  end
end
