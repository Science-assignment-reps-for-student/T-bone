class CreateHomeworks < ActiveRecord::Migration[6.0]
  def change
    create_table :homeworks do |t|

      t.timestamp :homework_1_deadline, null: false
      t.timestamp :homework_2_deadline, null: false
      t.timestamp :homework_3_deadline, null: false
      t.timestamp :homework_4_deadline, null: false
      t.string :homework_title, null: false
      t.string :homework_description, null: false
      t.integer :homework_type, null: false
      t.timestamp :created_at, null: false
    end
  end
end
