class CreateAuthCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :auth_codes do |t|

      t.string :auth_code, null: false, unique: true
      t.integer :user_number, null: false, unique: true
    end
  end
end
