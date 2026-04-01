require 'rails_helper'

describe NewsPost do
end

# ## Schema Information
#
# Table name: `news_posts`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`body`**              | `text`             |
# **`draft`**             | `boolean`          | `default(FALSE), not null`
# **`end_date`**          | `datetime`         |
# **`note`**              | `text`             |
# **`position`**          | `integer`          |
# **`start_date`**        | `datetime`         |
# **`title`**             | `text`             |
# **`url`**               | `string`           |
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
# **`required_role_id`**  | `bigint`           | `default(1), not null`
# **`user_id`**           | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_news_posts_on_user_id`:
#     * **`user_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`required_role_id => roles.id`**
# * `fk_rails_...`:
#     * **`user_id => users.id`**
#
