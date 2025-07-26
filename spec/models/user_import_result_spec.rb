require 'rails_helper'

describe UserImportResult do
  #pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: user_import_results
#
#  id                  :bigint           not null, primary key
#  body                :text
#  error_message       :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  user_id             :bigint
#  user_import_file_id :bigint
#
# Indexes
#
#  index_user_import_results_on_user_id              (user_id)
#  index_user_import_results_on_user_import_file_id  (user_import_file_id)
#
