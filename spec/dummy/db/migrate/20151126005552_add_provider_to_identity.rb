class AddProviderToIdentity < ActiveRecord::Migration[5.2]
  def change
    add_column :identities, :provider, :string
  end
end
