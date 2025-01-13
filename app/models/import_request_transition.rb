class ImportRequestTransition < ApplicationRecord
  belongs_to :import_request, inverse_of: :import_request_transitions
end

# == Schema Information
#
# Table name: import_request_transitions
#
#  id                :bigint           not null, primary key
#  to_state          :string
#  metadata          :jsonb            not null
#  sort_key          :integer
#  import_request_id :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  most_recent       :boolean          not null
#
