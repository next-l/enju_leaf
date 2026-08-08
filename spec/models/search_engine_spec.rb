require 'rails_helper'

describe SearchEngine do
  fixtures :search_engines

  it "should respond to search_params" do
    search_engines(:search_engine_00001).search_params('test').should eq({ submit: 'Search', locale: 'ja', keyword: 'test' })
  end
end

# ## Schema Information
#
# Table name: `search_engines`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`additional_param`**  | `text`             |
# **`base_url`**          | `text`             | `not null`
# **`display_name`**      | `text`             |
# **`http_method`**       | `text`             | `not null`
# **`name`**              | `string`           | `not null`
# **`note`**              | `text`             |
# **`position`**          | `integer`          |
# **`query_param`**       | `text`             | `not null`
# **`url`**               | `string`           | `not null`
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
#
