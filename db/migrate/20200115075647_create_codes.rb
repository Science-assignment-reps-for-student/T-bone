class CreateCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :codes do |t|

      t.string :auth_code, null: false, unique: true
      t.references :user, index: true
    end
  end
end
