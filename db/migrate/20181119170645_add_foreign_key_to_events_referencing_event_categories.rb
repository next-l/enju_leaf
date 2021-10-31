class AddForeignKeyToEventsReferencingEventCategories < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :events, :event_categories
  end
end
