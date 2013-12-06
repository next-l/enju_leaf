class RemoveAuthorFromNacsisUserRequests < ActiveRecord::Migration
  def up
    remove_column :nacsis_user_requests, :author
  end

  def down
    add_column :nacsis_user_requests, :author, :string
  end
end
