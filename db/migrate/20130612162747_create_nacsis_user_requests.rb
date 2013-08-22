class CreateNacsisUserRequests < ActiveRecord::Migration
  def change
    create_table :nacsis_user_requests do |t|
      t.string :subject_heading
      t.text :author
      t.string :publisher
      t.string :pub_date
      t.string :physical_description
      t.string :series_title
      t.text :note
      t.string :isbn
      t.string :pub_country
      t.string :title_language
      t.string :text_language
      t.string :classmark
      t.text :author_heading
      t.text :subject
      t.string :ncid
      t.integer :user_id, :null => false
      t.integer :request_type, :null => false
      t.integer :state, :null => false, :default => 1
      t.text :user_note
      t.text :librarian_note

      t.timestamps
    end
  end
end
