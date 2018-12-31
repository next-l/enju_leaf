class AddProviderToIdentity < ActiveRecord::Migration[4.2]
  def change
    add_column :identities, :provider, :string
  end
end
