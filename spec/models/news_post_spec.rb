require 'rails_helper'

describe NewsPost do
end

# == Schema Information
#
# Table name: news_posts
#
#  id               :integer          not null, primary key
#  title            :text
#  body             :text
#  user_id          :integer
#  start_date       :datetime
#  end_date         :datetime
#  required_role_id :integer          default(1), not null
#  note             :text
#  position         :integer
#  draft            :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  url              :string
#
