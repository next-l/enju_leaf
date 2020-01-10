class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles, comment: 'プロフィール' do |t|
      t.string :locale, comment: 'ロケール'
      t.string :user_number, comment: '利用者番号'
      t.text :full_name, comment: '氏名'
      t.text :note, comment: '備考'
      t.text :keyword_list, comment: 'キーワードリスト'
      t.references :required_role, foreign_key: {to_table: :roles}, comment: '参照に必要な権限'

      t.timestamps
    end

    add_index :profiles, :user_number, unique: true
  end
end
