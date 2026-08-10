require 'rails_helper'

describe ManifestationReserveStat do
  fixtures :manifestation_reserve_stats

  it "calculates manifestation count" do
    old_message_count = Message.count
    expect(manifestation_reserve_stats(:one).transition_to!(:started)).to be_truthy
    expect(Message.count).to eq old_message_count + 1
    expect(Message.order(:id).last.subject).to eq '[Enju Library] 集計が完了しました'
  end

  it "should calculate in background" do
    expect(ManifestationReserveStatJob.perform_later(manifestation_reserve_stats(:one))).to be_truthy
  end
end

# ## Schema Information
#
# Table name: `manifestation_reserve_stats`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`end_date`**    | `datetime`         | `not null`
# **`note`**        | `text`             |
# **`start_date`**  | `datetime`         | `not null`
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
# **`user_id`**     | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_manifestation_reserve_stats_on_user_id`:
#     * **`user_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`user_id => users.id`**
#
