require 'spec_helper'

describe Role do
  # pending "add some examples to (or delete) #{__FILE__}"
  fixtures :roles

  it "should not be saved if name is blank" do
    role = Role.first
    role.name = ''
    expect { role.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "should not be saved if name is not unique" do
    role = Role.first
    expect { Role.create!(name: role.name) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "should respond to localized_name" do
    expect(roles(:role_00001).display_name).to eq 'Guest'
  end

  it "should respond to default" do
    expect(Role.default).to eq roles(:role_00001)
  end
end

# ## Schema Information
#
# Table name: `roles`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `bigint`           | `not null, primary key`
# **`display_name`**  | `string`           |
# **`name`**          | `string`           | `not null`
# **`note`**          | `text`             |
# **`position`**      | `integer`          |
# **`score`**         | `integer`          | `default(0), not null`
# **`created_at`**    | `datetime`         | `not null`
# **`updated_at`**    | `datetime`         | `not null`
#
# ### Indexes
#
# * `index_roles_on_lower_name` (_unique_):
#     * **`lower((name)::text)`**
#
