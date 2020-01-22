class CreateHomeworks < ActiveRecord::Migration[6.0]
  def change
    create_table :homeworks do |t|

      t.bigint :homework_1_deadline, null: false
      t.bigint :homework_2_deadline, null: false
      t.bigint :homework_3_deadline, null: false
      t.bigint :homework_4_deadline, null: false
      t.string :homework_title, null: false
      t.string :homework_description, null: false
      t.integer :homework_type, null: false
      t.bigint :created_at, null: false
    end
  end
end
