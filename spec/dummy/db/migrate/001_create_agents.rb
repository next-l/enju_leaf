class CreateAgents < ActiveRecord::Migration[5.1]
  def change
    create_table :agents do |t|
      t.string :last_name
      t.string :middle_name
      t.string :first_name
      t.string :last_name_transcription
      t.string :middle_name_transcription
      t.string :first_name_transcription
      t.string :corporate_name
      t.string :corporate_name_transcription
      t.string :full_name
      t.text :full_name_transcription
      t.text :full_name_alternative
      t.timestamps
      t.string :zip_code_1
      t.string :zip_code_2
      t.text :address_1
      t.text :address_2
      t.text :address_1_note
      t.text :address_2_note
      t.string :telephone_number_1
      t.string :telephone_number_2
      t.string :fax_number_1
      t.string :fax_number_2
      t.text :other_designation
      t.text :place
      t.string :postal_code
      t.text :street
      t.text :locality
      t.text :region
      t.datetime :date_of_birth
      t.datetime :date_of_death
      t.integer :language_id, default: 1, null: false
      t.integer :country_id, default: 1, null: false
      t.integer :agent_type_id, default: 1, null: false
      t.integer :lock_version, default: 0, null: false
      t.text :note
      t.integer :required_role_id, null: false, default: 1
      t.text :email
      t.text :url
    end
    add_index :agents, :language_id
    add_index :agents, :country_id
    add_index :agents, :full_name
  end
end
