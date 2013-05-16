class CreateBindingShelf < ActiveRecord::Migration
  def up
    library = Library.real.first
    if library
      Shelf.create(:name => 'binding_shelf', :display_name => I18n.t('activerecord.models.binding_item'), :library_id => library.id)
    end
  end

  def down
    Shelf.where(:name => 'binding_shelf').first.destroy
  end
end
