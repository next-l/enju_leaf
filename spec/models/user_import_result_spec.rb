# -*- encoding: utf-8 -*-
require 'spec_helper'

describe UserImportResult do
  #pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: user_import_results
#
#  id                  :integer          not null, primary key
#  user_import_file_id :integer
#  user_id             :integer
#  body                :text
#  created_at          :datetime
#  updated_at          :datetime
#  error_message       :text
#
