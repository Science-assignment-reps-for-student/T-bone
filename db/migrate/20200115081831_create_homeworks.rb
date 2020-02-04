class CreateHomeworks < ActiveRecord::Migration[6.0]
  def change
    create_table :homeworks do |t|

      t.datetime :homework_1_deadline, null: false
      t.datetime :homework_2_deadline, null: false
      t.datetime :homework_3_deadline, null: false
      t.datetime :homework_4_deadline, null: false
      t.string :homework_title, null: false
      t.string :homework_description, null: false
      t.integer :homework_type, null: false
      t.datetime :created_at, null: false
    end
  end
end
