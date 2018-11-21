class CreateUserGroupHasCheckoutTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :user_group_has_checkout_types do |t|
      t.references :user_group, foreign_key: true, null: false, type: :uuid
      t.references :checkout_type, foreign_key: true, null: false
      t.integer :checkout_limit, default: 0, null: false
      t.integer :checkout_period, default: 0, null: false
      t.integer :checkout_renewal_limit, default: 0, null: false
      t.integer :reservation_limit, default: 0, null: false
      t.integer :reservation_expired_period, default: 7, null: false
      t.boolean :set_due_date_before_closing_day, default: false, null: false
      t.datetime :fixed_due_date
      t.text :note
      t.integer :position

      t.timestamps
    end
  end
end
