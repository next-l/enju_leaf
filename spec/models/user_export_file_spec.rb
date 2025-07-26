require 'rails_helper'
  
describe UserExportFile do
  fixtures :all
  
  it "should export users" do
    message_count = Message.count
    file = UserExportFile.create(user: users(:admin))
    file.export!
    #UserExportFileJob.perform_later(file).should be_truthy
    Message.count.should eq message_count + 1
    Message.order(:created_at).last.subject.should eq "Export completed: #{file.id}"
  end
end

# ## Schema Information
#
# Table name: `user_export_files`
#
# ### Columns
#
# Name                            | Type               | Attributes
# ------------------------------- | ------------------ | ---------------------------
# **`id`**                        | `bigint`           | `not null, primary key`
# **`executed_at`**               | `datetime`         |
# **`user_export_content_type`**  | `string`           |
# **`user_export_file_name`**     | `string`           |
# **`user_export_file_size`**     | `bigint`           |
# **`user_export_updated_at`**    | `datetime`         |
# **`created_at`**                | `datetime`         | `not null`
# **`updated_at`**                | `datetime`         | `not null`
# **`user_id`**                   | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_user_export_files_on_user_id`:
#     * **`user_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`user_id => users.id`**
#
