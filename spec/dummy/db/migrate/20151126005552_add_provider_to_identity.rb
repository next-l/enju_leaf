class AddProviderToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :provider, :string
  end
end
