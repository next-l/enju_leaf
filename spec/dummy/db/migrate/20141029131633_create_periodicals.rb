class CreatePeriodicals < ActiveRecord::Migration[5.1]
  def change
    create_table :periodicals, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.text :original_title
      t.string :periodical_type
      t.references :manifestation, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
