class AddMissingIssueToManifestations < ActiveRecord::Migration
  def change
    add_column :manifestations, :missing_issue, :integer
  end
end
