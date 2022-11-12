require 'rails_helper'

describe UserImportResult do
  #pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: user_import_results
#
#  id                  :bigint           not null, primary key
#  user_import_file_id :integer
#  user_id             :integer
#  body                :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  error_message       :text
#
