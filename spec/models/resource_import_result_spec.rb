require 'rails_helper'

describe ResourceImportResult do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: resource_import_results
#
#  id                      :bigint           not null, primary key
#  resource_import_file_id :bigint
#  manifestation_id        :bigint
#  item_id                 :bigint
#  body                    :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  error_message           :text
#
