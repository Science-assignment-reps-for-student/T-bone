class CreateHomeworks < ActiveRecord::Migration[6.0]
  def change
    create_table :homeworks do |t|

      t.integer :homework_1_deadline, null: false
      t.integer :homework_2_deadline, null: false
      t.integer :homework_3_deadline, null: false
      t.integer :homework_4_deadline, null: false
      t.string :homework_title, null: false
      t.string :homework_description, null: false
      t.integer :homework_type, null: false
      t.integer :created_at, null: false
    end
  end
end
