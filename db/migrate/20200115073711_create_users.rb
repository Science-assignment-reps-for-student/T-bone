class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|

      t.string :user_email, null: false, unique: true
      t.string :user_pw, null: false
      t.integer :user_number, unique: true
      t.string :user_name, null: false
      t.integer :user_type, default: 0
    end
  end
end
