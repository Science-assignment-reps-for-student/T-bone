class CreateAuthEmail < ActiveRecord::Migration[6.0]
  def change
    create_table :auth_emails do |t|
      t.string :auth_email, null: false, unique: true
      t.string :email_code, null: false, unique: true
      t.string :auth_state, null: false
    end
  end
end
